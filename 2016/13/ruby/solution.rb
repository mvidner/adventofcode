#!/usr/bin/env ruby

$timer = 0
$timer_step = 1000

class Map
  attr_accessor :rows

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
    raise "Bad goal" if @rows[@fy][@fx] == "#"

    @steps = 0

    @x = 1
    @y = 1
    @rows[@y][@x] = "O"
  end

  def dup
    copy = super
    copy.rows = @rows.map do |r|
      r.dup
    end
    copy
  end


  def go(x, y)
    @x = x
    @y = y
    trace
    check!
    @rows[y][x] = "O"
#    puts "go #{x} #{y}"
#    print_map
  end

  # @return the initial state
  def free?(x, y)
    s = x*x + 3*x + 2*x*y + y + y*y
    s += @key
    format("%b", s).count("1").even?
  end

  def print_map
    0.upto(@height - 1).map do |y|
      0.upto(@width - 1).map do |x|
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
    if a > 0
      1
    elsif a < 0
      -1
    else
      0
    end
  end

  def check!
    if @x == @fx && @y == @fy
      puts "GOAL, in #{@steps} steps"
      exit
    end
  end

  def pause
    puts "Press Enter"
    readline
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
    if dy < 11
      print_map
      p [dx, dy]
      p [sx, sy]
      p ss
      pause
      $timer_step = 1
    end
    if false && dx == 0
      pause
      p [dx, dy]
      p [sx, sy]
      p ss
    end
    ss
  end

  def step
#    check!

    bs = best_steps
    bs.each_with_index do |d, i|
      dx, dy = d
      ny = @y + dy
      nx = @x + dx
      if nx < 0 || ny < 0 || nx >= @width || ny >= @height
        print "@"
        next
      end

      if @rows[ny][nx] == "."
        @steps += 1
        go(nx, ny)

        dup.step
      end
      print "##{i} of #{bs} failed\n"
    end
    # we have exhausted all steps
#    print "!"
  end

  def trace
    $timer += 1
    return unless 0 == $timer % $timer_step
    puts
    print_map
    puts $timer
  end
end

test = Map.new(10, 8, 7, 4, 10)
# test.step

part_a = Map.new(50, 50, 31, 39, 1352)
part_a.step

m = Map.new(15, 15, 10, 8, 1352)
# m.step
