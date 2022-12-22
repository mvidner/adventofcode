#!/usr/bin/env ruby

# Coords: row (growing down), col

class Step
  # Specified direction numbers: 0 right, 1 down, 2 left, 3 up
  DELTA = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ]

  FACES = [">", "v", "<", "^"]

  # exactly one of :angle, distance is not zero

  # +1 to the right/clockwise
  # -1 left, ccw
  attr_reader :angle
  # @return [Integer]
  attr_reader :distance
  def initialize(angle, distance)
    raise if angle == 0 && distance == 0
    @angle = angle
    @distance = distance
  end

  # @return [Array<Step>]
  def self.parse(text)
    i = 0
    result = []
    loop do
      case text[i..-1]
      when ""
        break
      when /^(\d+)/
        distance = $1.to_i
        result << Step.new(0, distance)
        i += $1.size
      when /^L/
        result << Step.new(-1, 0)
        i += 1
      when /^R/
        result << Step.new(1, 0)
        i += 1
      else
        raise text[i, 5].inspect
      end
    end
    result
  end
end

# Tiles:
# Open '.' (or ^v<> if we've been here);
#   detect only Void and Wall to avoid being confused by trail marks
# Wall '#'
# Void ' '
class Map
  def initialize(text)
    @rows = text.lines.map(&:chomp)

    # but they are ragged at the right! rectangularize!
    width = @rows.map(&:size).max
    @rows.each do |r|
      newr = r + (" " * (width - r.size))
      r.replace(newr)
    end

    @dir = 0 # right
    @pos = [0, @rows[0].index(".")]
    snail_mark
  end

  def snail_mark
    @rows[@pos[0]][@pos[1]] = Step::FACES[@dir]
  end

  def dump
    cols = @rows[0].size.times.map { |c| format("%3d", c) }
    col_labels = lambda do
      cols[0].size.times.map do |i|
        digits = cols.map { |s| s[i] }.join
        puts digits unless digits.strip.empty?
      end
    end

    col_labels.call
    @rows.each_with_index do |r, i|
      puts "#{r}| #{i}"
    end
    col_labels.call
  end

  def go(steps)
    steps.each do |step|
      go1(step)
    end
    # puts "Final #{[@dir, @pos].inspect}"
  end

  def go1(step)
    if $sus
      puts
      puts "At #{[@dir, @pos].inspect}"
      puts "Go1 #{step.inspect}"
    end

    if step.distance == 0
      @dir = (@dir + step.angle) % Step::DELTA.size
      snail_mark
      return
      # that was easy
    end

    step.distance.times do
      drow, dcol = Step::DELTA[@dir]
      ndir, npos = wrap_step(@pos[0], @pos[1], drow, dcol)
      nrow, ncol = npos
      return if @rows[nrow][ncol] == "#"

      @dir = ndir
      @pos = nrow, ncol
      snail_mark
    end
  end

  # Do a single step, wrapping around the edges and skipping the Void
  # return [dir, [row, col]] with Open or Wall, not Void
  def wrap_step(row, col, drow, dcol)
    puts "WS #{row}, #{col}, #{drow}, #{dcol}" if $sus

    loop do
      row = (row + drow) % @rows.size
      col = (col + dcol) % @rows[row].size
      # stepped, possibly wrapped
      tile = @rows[row][col]
      break unless tile == " "
    end

    [@dir, [row, col]]
  end

  def password
    1000 * (@pos[0] + 1) + 4 * (@pos[1] + 1 ) + @dir
  end
end

Transition = Struct.new(:new_ro, :new_co, :dir_change) do
  # dir_change is +1 for CW (clockwise), -1 CCW (counterclockwise),
  #   0 none, 2 U-turn;
  #   and these match with Step::DELTA and FACES

  # ro and co are row offset, column offset, within their face, that is
  # 0 <= ro, co < esize (edge size)

  # The values of new_ro, new_co are symbols, meaning
  # :ro, :co - just copy the old row or column offset
  # :iro, :ico - inverted offset:
  #   input ranges from 0 to esize-1, output goes inversely from esize-1 to 0;
  #   In some special cases input is only 0 or esize-1 which originally
  #   lead me to introducew :wro, :wco with wrapping
end

# typing shortcut
class T
  def self.[](r, c, d)
    Transition.new(r, c, d)
  end
end

class CubeMap < Map
  JOIN_LR = T[:ro, :ico, 0]
  JOIN_UD = T[:iro, :co, 0]

  # quadrants:
  #
  # Q1 | Q0
  # ---+---
  # Q2 | Q3
  ROT_Q0_CW = ROT_Q2_CW = T[:ico, :iro, 1]
  ROT_Q0_CCW = ROT_Q2_CCW = T[:ico, :iro, -1]
  ROT_Q1_CW = ROT_3_CW = T[:co, :ro, 1]
  ROT_Q1_CCW = ROT_3_CCW = T[:co, :ro, -1]

  UTURN_LR = T[:iro, :co, 2]
  UTURN_UD = T[:ro, :ico, 2]

  NOFACE = {}
  TRANSITIONS_SAMPLE = [
    [
      NOFACE,
      NOFACE,
      { u: UTURN_UD, l: ROT_Q1_CCW, d: JOIN_UD, r: UTURN_LR },
      NOFACE
    ],
    [
      { u: UTURN_UD, l: ROT_Q0_CW, d: UTURN_UD, r: JOIN_LR },
      { u: ROT_Q1_CW, l: JOIN_LR, d: ROT_Q2_CCW, r: JOIN_LR },
      { u: JOIN_UD, l: JOIN_LR, d: JOIN_UD, r: ROT_Q0_CW },
      NOFACE
    ],
    [
      NOFACE,
      NOFACE,
      { u: JOIN_UD, l: ROT_Q2_CW, d: UTURN_UD, r: JOIN_LR },
      { u: ROT_Q0_CCW, l: JOIN_LR, d: ROT_Q0_CCW, r: UTURN_LR }
    ]
  ]

  # Do a single step, wrapping around cube edges
  # return [dir, [row, col]] with Open or Wall, not Void
  def wrap_step(row, col, drow, dcol)
    # row face, col face - including nonexistent faces
    rowf = row / esize
    colf = col / esize

    nrow = (row + drow) % @rows.size
    ncol = (col + dcol) % @rows[row].size
    nrowf = nrow / esize
    ncolf = ncol / esize

    # not void, simple case
    #
    # oops, wrong for sample!
    # can wrap from bottom to top over 3 squares , missing the correct cube wrap
    return [@dir, [nrow, ncol]] if @rows[nrow][ncol] != " "

    raise "cube wrap #{[row, col]} -> #{[nrow, ncol]} faces #{[rowf, colf]} -> #{[nrowf, ncolf]}"
  end

  # edge size
  def esize
    return @esize if @esize
    # FIXME: only works for my sample and input map layout
    esize = [@rows.size / 3, @rows[0].size / 3].min
    puts "esize #{esize}" if $sus
    @esize = esize
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  map_text, path_text = text.split("\n\n")

  steps = Step.parse(path_text.chomp)

  map = Map.new(map_text)
  map.go(steps)
  map.dump
  puts "Password: #{map.password}"

  cmap = CubeMap.new(map_text)
  cmap.go(steps)
  cmap.dump
  puts "Password: #{cmap.password}"
end
