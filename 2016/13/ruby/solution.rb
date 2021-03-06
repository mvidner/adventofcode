#!/usr/bin/env ruby
require "set"

$timer = 0
$timer_step = 1000

class Map
  attr_accessor :rows
  attr_reader :reached

  def initialize(width, height, finish_x, finish_y, key)
    @width = width
    @height = height
    @fx = finish_x
    @fy = finish_y
    @key = key

    @rows = 0.upto(@height - 1).map do |y|
      0.upto(@width - 1).map do |x|
        free?(x, y) ? "." : "#"
      end
    end
    raise "Bad goal" if @fy && @rows[@fy][@fx] == "#"

    @steps = 0
    @reached = 0
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

  # @return the initial state
  def free?(x, y)
    s = x*x + 3*x + 2*x*y + y + y*y
    s += @key
    format("%b", s).count("1").even?
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

  def reach(start_x, start_y, limit)
    current_generation = Set.new
    next_generation = Set.new
    next_generation << [start_x, start_y]

    # >= 0: no steps means visit the 1 initial position
    while limit >= 0
      limit -= 1
      current_generation = next_generation
      next_generation = Set.new

      current_generation.each do |x, y|
        # They may point to unavailable/already visited cells
        # so resolve it now
        case @rows[y][x]
        when "#", "O"
          nil
        when "."
          @reached += 1
          @rows[y][x] = "O"
          next_generation.merge(steps_within_board(x, y))
          # mistake: finding the next step even though the current one
          # ended in a wall
        else
          raise
        end
      end
    end
    self
  end
end

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
