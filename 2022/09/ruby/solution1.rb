#!/usr/bin/ruby
require "set"

# xy coords, y positive up
class Rope
  attr_reader :tvisited
  
  def initialize(commands)
    @hx = @hy = @tx = @ty = 0
    @tvisited = Set.new

    commands.each { |c| go(c) }
  end

  def go(cmd)
    case cmd
    when /U (\d+)/
      $1.to_i.times { go1(0, 1)}
    when /D (\d+)/
      $1.to_i.times { go1(0, -1)}
    when /L (\d+)/
      $1.to_i.times { go1(-1, 0)}
    when /R (\d+)/
      $1.to_i.times { go1(1, 0)}
    else
      raise
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
      
  def go1(dx, dy)
    @hx += dx
    @hy += dy

    ddx = @hx - @tx
    ddy = @hy - @ty
    if ddx.abs == 2
      @tx += sgn(ddx)
      @ty = @hy
    end
    if ddy.abs == 2
      @ty += sgn(ddy)
      @tx = @hx
    end

    @tvisited << "#{@tx},#{@ty}"
  end

end

text = File.read(ARGV[0] || "input.txt")
input = text.lines

rope = Rope.new(input)
p rope.tvisited.size
