#!/usr/bin/env ruby
require "set"

Point = Struct.new(:x, :y) do
  include Comparable

  def <=>(other)
    [x, y] <=> [other.x, other.y]
  end

  def rectangle_area(other)
    ((x - other.x).abs + 1) * ((y - other.y).abs + 1)
  end

  # @return [(Point, Point, Point, Point)] even for degenerate cases with equal coords
  def rectangle_corners(other)
    xs = [x, other.x].sort
    ys = [y, other.y].sort
    xs.product(ys).map { |x, y| self.class.new(x, y) }
  end
end

VerticalEdge = Struct.new(:x, :y_range) do
end

class OrthogonalPolygon
  attr_reader :points

  # sorted by x
  attr_reader :vertical_edges

  def self.from_file(filename)
    text = File.read(filename)
    points = text.lines.map do |line|
      x, y = line.split(",").map(&:to_i)
      Point.new(x, y)
    end
    new(points)
  end

  def initialize(points)
    raise "Too few points (#{points.size})" if points.size < 4

    @points = points

    @vertical_edges = []
    # cons are overlapping consecutive tuples (not slices)
    (@points + [@points.first]).each_cons(2) do |a, b|
      if a.x == b.x
        y_range = Range.new(* [a.y, b.y].sort) # inclusive range
        @vertical_edges << VerticalEdge.new(a.x, y_range)
      else
        raise "Edge not orthogonal: #{a.inspect}--#{b.inspect}" unless a.y == b.y
      end
    end

    @vertical_edges.sort_by!(&:x)
    pp self if $DEBUG
  end

  # corners and border does count as inside
  def inside?(point)
    x, y = point.x, point.y

    # Cast a ray from `point` to the left
    # and count the times it intersects the vertical edges
    candidates = @vertical_edges.find_all { |e| e.y_range.cover?(y) }

    # prune the edges that merge with respect to ray casting
    mcandidates = []
    candidates.each_with_index do |e, i|
      result = if i + 1 < candidates.size
        e2 = candidates[i + 1]
        r1 = e.y_range
        r2 = e2.y_range
        if (y == r1.begin && y == r2.end) || (y == r2.begin && y == r1.end)
          puts "  merging #{e.inspect} with #{e2.inspect}" if $DEBUG
          nil
        else
          e
        end
      else
        e
      end

      mcandidates << result unless result.nil?
    end
    candidates = mcandidates

    # Array#bsearch and Array#bsearch_index note:
    # In find-minimum mode which we use,
    # it expects that theblock returns
    # false for smaller indices, and
    # true for indices greater or equal than the sought one

    # greater_or_equal_edge_index
    goei = candidates.bsearch_index { |e| e.x >= point.x }
    return false if goei.nil?

    equal = candidates[goei].x == point.x
    inside = goei.odd? || equal
    puts "  #{inside ? 'IN ' : 'OUT'} #{point.inspect}" if $DEBUG
    inside
  end
end

class Floor < OrthogonalPolygon
  def max_red_area
    max = 0

    @points.each do |a|
      @points.each do |b|
        next if a >= b

        area = a.rectangle_area(b)
        max = area if max < area
      end
    end

    max
  end

  def max_red_area_within_green
    max = 0

    @points.each do |a|
      @points.each do |b|
        next if a >= b

        puts "Points: #{[a, b].inspect}" if $DEBUG
        corners = a.rectangle_corners(b)
        next if corners.any? { |p| !inside?(p) }

        area = a.rectangle_area(b)
        puts " inside, area is #{area}" if $DEBUG
        max = area if max < area
      end
    end

    max
  end
end

if $PROGRAM_NAME == __FILE__
  f = Floor.from_file(ARGV[0] || "input.txt")

  puts "Maximal red rectangle: #{f.max_red_area}"
  puts "Maximal red rectangle within green area: #{f.max_red_area_within_green}"
end
