#!/usr/bin/env ruby
require "set"

Pos = Struct.new(:r, :c) do
  def +(pair)
    Pos.new(r + pair[0], c + pair[1])
  end
end

# Noticing that the collision detection works on black and white,
# and that we may need very efficient storage,
# I' represent the board positions, and tile units, with BITS in integers
# (and maybe in ASCII characters)

tile_shapes = [
  [
    "####"
  ],
  [
    ".#.",
    "###",
    ".#."
  ],
  [
    "..#",
    "..#",
    "###"
  ],
  [
    "#",
    "#",
    "#",
    "#"
  ],
  [
    "##",
    "##"
  ],
]

# A tile is a rectangle of empty spaces and rocks, represented by
# an array (lines) of bits (0 space, 1 rock) representing Integers
# (later maybe compress it further into a binary string)
# where the LSB is at the right,
# and first row is the BOTTOM one.
class Tile < Array
  def self.parse_shape(shape_lines)
    # input is visual, first at top, reverse it for first at bottom
    rows = shape_lines.reverse.map do |l|
      l.tr(".#", "01").to_i(2)
    end
    new(rows)
  end

  def initialize(rows, width: nil)
    super()
    replace(rows)
    @width = width || self.map { |r| r.bit_length }.max
  end

  attr_reader :width

  # @param count [Integer] may be negative to shift left
  # @return [Tile] a new tile, or nil if we'd shift outside valid_width
  def shift_right(count, valid_width)
    raise ArgumentError if count == 0

    # should unit test this :-)
    if count > 0
      fail_mask = (1 << count) - 1
    else
      fail_mask = ~((1 << (valid_width + count)) - 1)
    end

    nrows = self.map do |r|
      return nil if r & fail_mask != 0
      r >> count
    end
    Tile.new(nrows, width: @width)
  end
end

TILES = tile_shapes.map { |rows| Tile.parse_shape(rows) }

class Tetris
  LEFT_PAD = 2
  BOTTOM_PAD = 3
  WIDTH = 7

  def initialize(instructions, caching: false)
    @caching = caching

    puts "(with #{instructions.size} instructions)"
    @instructions = instructions
    # grows modulo @instructions
    @next_instruction = 0
    # grows by 1
    @step = 0

    @height = 0
    @next_tile_i = 0

    # row 0 is bottom
    # row elements are bits as integers, see Tile
    @rows = []
    # step in which this row was added
    @rows_birth = []
    @tile = []
  end

  # distance of topmost rock from the floor
  attr_reader :height

  def dump_part(rows, visual, row_offset: 0, rows_birth: nil)
    dump_padding = visual[0] * WIDTH
    (rows.size - 1).downto(0) do |ri|
      r = rows[ri]
      sr = dump_padding + r.to_s(2).tr("01", visual)
      sr = sr[-WIDTH .. -1]
      birth = ""
      birth = rows_birth[ri + row_offset] if rows_birth
      puts "|#{sr}| #{ri + row_offset} #{birth}"
    end
  end

  def dump
    puts "TILE"
    dump_part(@tile, " @", row_offset: @tile_bottom)
    puts

    puts "TOWER"
    dump_part(@rows, ".#", rows_birth: @rows_birth)
    puts "+#{"-" * WIDTH}+"
    puts
  end

  # Drop one tile until it lands
  # using *instructions* on it as it falls
  #
  # @return nil or a pair (d_instructions, d_height) meaning
  #   a state repeats after *d_instructions* and the height has increased by *d_height*
  def drop
    spawn

    begin
      push
      landed = drop1
    end until landed

    commit

    if @caching
      cache2
    else
      nil
    end
  end

  def cache2
    return nil unless @next_instruction == 0

    @cache ||= {}
    @cache[@next_tile_i] ||= {}

    top_row = @rows[@height - 1]
    seen_height_m1 = @cache[@next_tile_i][top_row]

    if seen_height_m1
      puts "next_tile_i #{@next_tile_i}"
      puts "top_row #{top_row}"
      puts "previous h-1 #{seen_height_m1}"

      dump
      exit
    end

    @cache[@next_tile_i][top_row] = @height - 1

    nil
  end
  # @return nil or a pair (d_instructions, d_height) meaning
  #   a state repeats after *d_instructions* and the height has increased by *d_height*
  def cache
    top_row = @rows[@height - 1]
    @cache ||= {}
    @cache[@next_tile_i] ||= {}
    @cache[@next_tile_i][@next_instruction] ||= {}

    seen_height_m1 = @cache[@next_tile_i][@next_instruction][top_row]
    if seen_height_m1 && !@skip_dump
      p [@next_tile_i, @next_instruction, top_row]
      puts "previous h-1 #{seen_height_m1}"
      d_height = (@height - 1) - seen_height_m1
      puts "diff #{d_height}"

      puts "@step #{@step}"

      d_instructions = @step - @rows_birth[seen_height_m1]
      if d_instructions >= @instructions.size
        cycle = [d_instructions, d_height]
        puts "Cycle #{cycle.inspect}"
        dump unless @skip_dump
        # @skip_dump = true
        return cycle
      else
        puts "false cycle"
      end
    end

    @cache[@next_tile_i][@next_instruction][top_row] = @height - 1

    nil
  end

  def make_rows(count)
    Array.new(count, 0)
  end

  def spawn
    @step += 1

    @tile = TILES[@next_tile_i]
    @next_tile_i = (@next_tile_i + 1) % TILES.size

    # row where the bottom-most piece of the tile is
    @tile_bottom = @height + BOTTOM_PAD

    @tile = @tile.shift_right(-(WIDTH-@tile.width-LEFT_PAD), WIDTH)
  end

  def push
    instruction = @instructions[@next_instruction]
    @next_instruction = (@next_instruction + 1) % @instructions.size


    t = @tile.shift_right(instruction == ">" ? 1 : -1, WIDTH)

    # pushed against the wall
    return if t.nil?

    # collides with other tiles once at tower height
    return if @tile_bottom < @height && collision?(t, @tile_bottom)

    @tile = t
  end

  # @return [Boolean] true if landed
  def drop1
    if @tile_bottom > @height
      @tile_bottom -=1
      return false
    end

    new_tile_bottom = @tile_bottom - 1
    return true if new_tile_bottom == -1

    if collision?(@tile, new_tile_bottom)
      true
    else
      @tile_bottom = new_tile_bottom
      false
    end
  end

  def collision?(tile, tile_bottom)
    tile.each_with_index do |tr, tri|
      return true if tr & @rows.fetch(tri + tile_bottom, 0) != 0
    end
    false
  end

  def commit
    # add rows if needed
    add = @tile_bottom + @tile.size - @height
    if add > 0
      @rows.concat(Array.new(add, 0))
      @rows_birth.concat(Array.new(add, @step))
      @height += add
    end

    # add the tile bits
    @tile.each_with_index do |tr, tri|
      @rows[tri + @tile_bottom] |= tr
    end
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  instructions = text.chomp.chars

  tetris = Tetris.new(instructions)
  puts "Initially" if $sus
  tetris.dump if $sus

  2022.times do |i|
    tetris.drop
    puts "After #{i+1} drops" if $sus
    tetris.dump if $sus
  end

  puts "Finally"
  tetris.dump if $sus
  puts "Height: #{tetris.height}"

  puts
  puts "With caching"
  tetris = Tetris.new(instructions, caching: true)
  # many = 1_000_000_000_000
  many = 2022
  many = 10_000_000

  many.times do |i|
    cycle = tetris.drop
    if cycle
      #  (------------- i ------------)
      #  (~~start~~~)(.....d_instructions....)
      d_instructions, d_height = cycle

      # should be returning INSTEAD of performing the drop
      repeat, rest = (many - i).divmod(d_instructions)
      # h0 = tetris.height
      h1 = repeat * d_height

      puts "Rest #{rest}"
      rest.times { tetris.drop }
      h2 = tetris.height + h1
      puts "SPEEDUP final"
      tetris.dump
      puts "SPEEDUP height #{h2}"
      exit
    end
  end
end
