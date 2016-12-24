#!/usr/bin/env ruby
require "set"
require "pp"

class Map
  attr_accessor :rows
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

  def distances
    return @distances if @distances
    @distances = []
    @numbers.each do |x, y|
      @distances << dup.distances_from(x, y)
    end
    @distances
  end

  # return [length of Hamiltonian path, length of Hamiltonian cycle]
  def visit_all
    puts "Distance matrix:"
    pp distances

    min_path = (1 ... @numbers.size).to_a.permutation.map do |order|
      steps = 0
      current = 0
      order.each do |nxt|
        steps += distances[current][nxt]
        current = nxt
      end
      # return the path length
      [steps, steps + distances[current][0]]
    end.min

  end

  def dup
    copy = super
    copy.rows = @rows.map do |r|
      r.dup
    end
    copy
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

def solve(map)
  map.print_map
  path, cycle = map.visit_all
  puts "Minimal path #{path}"
  puts "Minimal return path #{cycle}"
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
solve(sample)

puts "Puzzle:"
map = Map.from_file("input.txt")
solve(map)
