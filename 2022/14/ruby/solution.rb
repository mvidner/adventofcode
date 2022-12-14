#!/usr/bin/env ruby

# In our world, Y grows downward!
Point = Struct.new(:x, :y)

class Sandfall
  # Sample text:
  #   498,4 -> 498,6 -> 496,6
  #   503,4 -> 502,4 -> 502,9 -> 494,9
  #
  # Resulting cave:
  #      4     5  5
  #      9     0  0
  #      4     0  3
  #    0 ......+...
  #    1 ..........
  #    2 ..........
  #    3 ..........
  #    4 ....#...##
  #    5 ....#...#.
  #    6 ..###...#.
  #    7 ........#.
  #    8 ........#.
  #    9 #########.
  def self.parse(text)
    paths = text.each_line.map do |line|
      points = line.split(" -> ").map do |point_s|
        point_s =~ /(-?\d+),(-?\d+)/
        Point.new($1.to_i, $2.to_i)
      end
      points
    end

    new(paths)
  end

  def initialize(paths)
    pf = paths.flatten
    @minx, @maxx = pf.map { |point| point.x }.minmax
    @miny, @maxy = pf.map { |point| point.y }.minmax
    @miny = 0 if @miny > 0
    @rows = Array.new(@maxy - @miny + 1) { "." * (@maxx - @minx + 1)}

    paths.each do |path|
      path.each_cons(2) do |from, to|
        draw_segment(from, to)
      end
    end

    @source = Point.new(500, 0)
    set(@source, "+")

    dump
  end

  def dump
    puts @rows
  end

  def get(p)
    get2(p.x, p.y)
  end

  def get2(x, y)
    @rows[y - @miny][x - @minx]
  end

  def set(p, val)      
    set2(p.x, p.y, val)
  end

  def set2(x, y, val)
    # p "set2 #{x} #{y} #{val}"
    @rows[y - @miny][x - @minx] = val
  end
  
  def draw_segment(from, to)
    if from.x == to.x
      draw_v(from, to)
    elsif from.y == to.y
      draw_h(from, to)
    else
      raise
    end
  end

  def draw_h(from, to)
    from, to = to, from if from.x > to.x
    (from.x .. to.x).each { |x| set2(x, to.y, "#")}
  end

  def draw_v(from, to)
    from, to = to, from if from.y > to.y
    (from.y .. to.y).each { |y| set2(to.x, y, "#")}
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  sf = Sandfall.parse(text)
end
