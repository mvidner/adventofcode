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
  # DUMP_PADDING = "." * WIDTH

  def initialize(moves)
    puts "#{moves.size} moves"
    @moves = moves
    @next_move = 0

    @height = 0
    @next_tile_i = 0

    # row 0 is bottom
    # row elements are bits as integers, see Tile
    @rows = []
    @tile = []
  end

  # distance of topmost rock from the floor
  attr_reader :height

  def dump_part(rows, visual, row_offset: 0)
    dump_padding = visual[0] * WIDTH
    (rows.size - 1).downto(0) do |ri|
      r = rows[ri]
      sr = dump_padding + r.to_s(2).tr("01", visual)
      sr = sr[-WIDTH .. -1]
      puts "|#{sr}| #{ri + row_offset}"
    end
  end

  def dump
    puts "TILE"
    dump_part(@tile, " @", row_offset: @tile_bottom)
    puts

    puts "TOWER"
    dump_part(@rows, ".#")
    puts "+#{"-" * WIDTH}+"
    puts
  end

  # Drop one tile until it lands
  # using *moves* on it as it falls
  def drop
    spawn

    begin
      push
      landed = drop1
    end until landed

    commit
  end

  def make_rows(count)
    Array.new(count, 0)
  end

  def spawn
    @tile = TILES[@next_tile_i]
    @next_tile_i = (@next_tile_i + 1) % TILES.size

#    @rows.concat(make_rows(BOTTOM_PAD))
#    @height += BOTTOM_PAD

    # row where the bottom-most piece of the tile is
    @tile_bottom = @height + BOTTOM_PAD

    # unnecessary rendering?
#    tile_height = @tile.size
#    fresh_rows = @tile.shift_right(-(WIDTH-@tile.width-LEFT_PAD))
#    @rows.concat(fresh_rows)
#    @height += tile_height

    @tile = @tile.shift_right(-(WIDTH-@tile.width-LEFT_PAD), WIDTH)
  end

  def push
    move = @moves[@next_move]
    @next_move = (@next_move + 1) % @moves.size


    t = @tile.shift_right(move == ">" ? 1 : -1, WIDTH)

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
  moves = text.chomp.chars

  tetris = Tetris.new(moves)
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
end
