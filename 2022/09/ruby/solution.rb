#!/usr/bin/ruby
require "set"

# xy coords, y positive up
class Rope
  attr_reader :tvisited
  
  def initialize(commands)
    @rope = Array.new(10) { [0, 0] }
    @tvisited = Set.new

    commands.each { |c| go(c) }
  end

  def dump(sx, sy)
    board = Array.new(sy) { "." * sx }
    (@rope.size - 1).downto(0) do |i|
      pos = @rope[i]
      mark = i.to_s
      mark = "H" if i == 0

      board[pos[1]][pos[0]] = mark
    end
    board.reverse_each do |row|
      puts row
    end
  end
  

  def go(cmd)
    # puts "GO #{cmd}"
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
#    puts cmd
#    puts "#{@hx},#{@hy} #{@tx},#{@ty}"
#    puts
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
    # puts "GO1 #{dx},#{dy}"
    h = @rope[0]
    h[0] += dx
    h[1] += dy

    (@rope.size-1).times { |hi| adjust(hi) }
    #p @rope
#    dump(6, 5)
    t = @rope.last
    tx, ty = t
    @tvisited << "#{tx},#{ty}"
  end

  # @param hi [Integer] head index
  # after a head has moved, adjust the position of the node behind it
  def adjust(hi)
    h = @rope[hi]
    t = @rope[hi+1]
    hx, hy = h
    tx, ty = t
    t0x, t0y = t

    ddx = hx - tx
    ddy = hy - ty
    raise if ddx.abs > 2 || ddy.abs > 2
    # print "adjust [#{hi+1}] #{ddx},#{ddy}"
    if ddx.abs == 2
      if ddy.abs == 2
        tx += sgn(ddx)
        ty += sgn(ddy)
      else
        tx += sgn(ddx)
        ty = hy
      end
    elsif ddy.abs == 2
      ty += sgn(ddy)
      tx = hx
    end
    # puts " -> #{tx-t0x}, #{ty-t0y}"

    @rope[hi+1] = [tx, ty]
  end

end

text = File.read(ARGV[0] || "input.txt")
input = text.lines

rope = Rope.new(input)
p rope.tvisited.size
