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
    @dir = 0 # right
    @pos = [0, @rows[0].index(".")]
    snail_mark
  end

  def snail_mark
    @rows[@pos[0]][@pos[1]] = Step::FACES[@dir]
  end

  def dump
    @rows.each do |r|
      puts r
    end
  end

  def go(steps)
    steps.each do |step|
      go1(step)
    end
    # puts "Final #{[@dir, @pos].inspect}"
  end

  def go1(step)
    # puts
    # puts "At #{[@dir, @pos].inspect}"
    # puts "Go1 #{step.inspect}"
    if step.distance == 0
      @dir = (@dir + step.angle) % Step::DELTA.size
      snail_mark
      return
      # that was easy
    end

    drow, dcol = Step::DELTA[@dir]
    step.distance.times do
      nrow, ncol = wrap_step(@pos[0], @pos[1], drow, dcol)
      return if @rows[nrow][ncol] == "#"

      @pos = nrow, ncol
      snail_mark
    end
  end

  # Do a single step, wrapping around the edges and skipping the Void
  # return [row, col] with Open or Wall, not Void
  def wrap_step(row, col, drow, dcol)
    # puts "WS #{row}, #{col}, #{drow}, #{dcol}"
    loop do
      row = (row + drow) % @rows.size
      col = (col + dcol) % @rows[row].size
      # stepped, possibly wrapped
      tile = @rows[row][col]
      break unless tile == " "
    end

    [row, col]
  end

  def password
    1000 * (@pos[0] + 1) + 4 * (@pos[1] + 1 ) + @dir
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  map_text, path_text = text.split("\n\n")

  map = Map.new(map_text)
  steps = Step.parse(path_text.chomp)
  map.go(steps)
  map.dump
  puts "Password: #{map.password}"
end
