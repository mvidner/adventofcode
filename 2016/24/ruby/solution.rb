#!/usr/bin/env ruby
require "set"
require "pp"

$timer = 0
$timer_step = 1


class Map
  attr_accessor :rows
  attr_reader :reached
  attr_reader :numbers

  def self.from_file(filename)
    Map.new(File.readlines(filename).map(&:chomp))
  end

  def initialize(rows)
    @rows = rows
    @width = @rows.first.size
    @height = @rows.size
    init_numbers
  end

  def init_numbers
    arr = []
    0.upto(@height - 1).each do |y|
      0.upto(@width - 1).each do |x|
        if @rows[y][x] =~ /(\d)/
          arr[$1.to_i] = [x, y]
        end
      end
    end
    @numbers = arr
  end

  # return index of manhattan-closest number from @x @y
  def closest
    distances = numbers.map do |pair|
      if pair.nil?
        Float::INFINITY
      else
        x, y = *pair
        (x - @x).abs + (y - @y).abs
      end
    end
    min = distances.min
    distances.index(min)
  end

  def distances
    return @distances if @distances
    @distances = []
    @numbers.each do |x, y|
      @distances << dup.distances_from(x, y)
    end
    @distances
  end

  def visit_all
    pp distances
    min_path = (1 ... @numbers.size).to_a.permutation.map do |order|
      steps = 0
      current = 0
      order.each do |nxt|
        steps += distances[current][nxt]
        current = nxt
      end
      # return the path length
      steps
    end.tap {|p| pp p}.min
    puts "Minimal path #{min_path}"

    min_path = (1 ... @numbers.size).to_a.permutation.map do |order|
      steps = 0
      current = 0
      order.each do |nxt|
        steps += distances[current][nxt]
        current = nxt
      end
      # return the path length
      steps + distances[current][0]
    end.tap {|p| pp p}.min
    puts "Minimal return path #{min_path}"

  end

  def dup
    copy = super
    copy.rows = @rows.map do |r|
      r.dup
    end
    copy
  end

  # @return [self] self if goal reached, otherwise nil
  def go(x, y)
    @x = x
    @y = y
    trace
    found = check!
    return found unless found.nil?

    @steps += 1
    @rows[y][x] = "O"
    nil
  end

  def print_map
    0.upto(@height - 1).each do |y|
      0.upto(@width - 1).each do |x|
        if x== @fx && y == @fy
          print "X"
        else
          print @rows[y][x]
        end
      end
      puts
    end
  end

  def sgn(a)
    return  1 if a > 0
    return -1 if a < 0
    0
  end

  def check!
    if @x == @fx && @y == @fy
      puts "GOAL, in #{@steps} steps"
      self
    else
      nil
    end
  end

  def best_steps
    dx = @fx - @x
    dy = @fy - @y
    sx = sgn(dx)
    sy = sgn(dy)
    if dx.abs > dy.abs
      sy = 1 if sy == 0
      ss = [[sx, 0], [0, sy], [0, -sy], [-sx, 0]]
    else
      sx = 1 if sx == 0
      ss = [[0, sy], [sx, 0], [-sx, 0], [0, -sy]]
    end
    ss
  end

  # @return [self] self if goal reached, otherwise nil
  def step(x, y)
    found = go(x, y)
    return found unless found.nil?

    bs = best_steps
    bs.each_with_index do |d, i|
      dx, dy = d
      ny = @y + dy
      nx = @x + dx
      if !within_board?(nx, ny)
        print "@"
        next
      end

      if @rows[ny][nx] == "."
        found = dup.step(nx, ny)
        return found unless found.nil?
      end
    end
    # we have exhausted all steps
    nil
  end

  def trace
    $timer += 1
    return unless 0 == $timer % $timer_step
    puts
    print_map
    puts $timer
  end

  def within_board?(x, y)
    x >= 0 && y >= 0 && x < @width && y < @height
  end

  STEPS = [[0, 1], [1, 0], [-1, 0], [0, -1]]
  def steps_within_board(x, y)
    r = STEPS.map {|dx,dy| [x+dx, y+dy]}.find_all {|x,y| within_board?(x,y) }
    r
  end

  # return array of distances to the numbers
  def distances_from(start_x, start_y)
    distances = Array.new(@numbers.size, nil)

    current_generation = Set.new
    next_generation = Set.new
    next_generation << [start_x, start_y]

    steps = 0

    loop do
      current_generation = next_generation
#      print_map
      next_generation = Set.new

      current_generation.each do |x, y|
        # They may point to unavailable/already visited cells
        # so resolve it now
        case @rows[y][x]
        when "#", "O"
          nil
        when "."
          @rows[y][x] = "O"
          next_generation.merge(steps_within_board(x, y))
          # mistake: finding the next step even though the current one
          # ended in a wall
        when /(\d)/
          # found a digit
          d = $1.to_i
          distances[d] = steps
#          p distances
          return distances unless distances.index(nil)
          @rows[y][x] = "O"
          next_generation.merge(steps_within_board(x, y))
        else
          raise
        end
      end
      steps +=1
    end
    steps
  end
end

puts "Sample:"
sample_str = <<EOS
###########
#0.1.....2#
#.#######.#
#4.......3#
###########
EOS
sample = Map.new(sample_str.split /\n/)
sample.print_map
p sample.numbers
sample.visit_all

puts "Part one:"
map = Map.from_file("input.txt")
puts "Numbers:"
p map.numbers
map.visit_all

exit

puts "Part A:"
test = Map.new(10, 8, 7, 4, 10)
# test.step(1, 1)

part_a = Map.new(50, 50, 31, 39, 1352)
found = part_a.step(1, 1)
found.print_map

m = Map.new(15, 15, 10, 8, 1352)
# m.step(1, 1)

puts "Part B:"
limit = 50
part_b0 = Map.new(limit+2, limit+2, nil, nil, 1352)

limit.upto(limit).each do |lim|
  part_b = part_b0.dup
  reached = part_b.reach(1, 1, lim)
  part_b.print_map
  puts "In #{lim} steps we can reach #{reached.reached} cells."
end
