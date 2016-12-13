#!/usr/bin/env ruby

if true
  $key = 1352
  $fx = 10
  $fy = 8
elsif false
  $key = 10
  $fx = 7
  $fy = 4
else
  $key = 1352
  $fx = 31
  $fy = 39
end

$timer = 0

class Map
  attr_accessor :rows

  def initialize(width, height)
    @width = width
    @height = height
    @rows = 0.upto(@height - 1).map do |y|
      0.upto(@width - 1).map do |x|
        free?(x, y) ? "." : "#"
      end
    end
    raise "Bad goal" if @rows[$fy][$fx] == "#"

    @steps = 0
    go(1, 1)
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
    check!
    @rows[y][x] = "O"
#    puts "go #{x} #{y}"
#    print_map
  end

  # @return the initial state
  def free?(x, y)
    s = x*x + 3*x + 2*x*y + y + y*y
    s += $key
    format("%b", s).count("1").even?
  end

  def print_map
    0.upto(@height - 1).map do |y|
      0.upto(@width - 1).map do |x|
        if x== $fx && y == $fy
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
    if @x == $fx && @y == $fy
      puts "GOAL, in #{@steps} steps"
      exit
    end
  end

  def best_steps
    dx = $fx - @x
    dy = $fy - @y
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

  def step
#    check!

    best_steps.each do |dx, dy|
      ny = @y + dy
      nx = @x + dx
      if nx < 0 || ny < 0 || nx >= @width || ny >= @height
        next
      end

      if @rows[ny][nx] == "."
        @steps += 1
        go(nx, ny)

        dup.step
      end
      trace
    end
    # we have exhausted all steps
    print "!"
  end

  def trace
    $timer += 1
    return unless 0 == $timer % 100
    puts
    print_map
    puts $timer
  end
end

m = Map.new(40, 20)
puts
m.print_map

m.step
