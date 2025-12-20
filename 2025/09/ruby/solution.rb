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

  def self.points_from_file(filename)
    text = File.read(filename)
    points = text.lines.map do |line|
      x, y = line.split(",").map(&:to_i)
      Point.new(x, y)
    end
    points
  end

  def self.from_file(filename)
    points = points_from_file(filename)
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
        # Does not happen in sample or input:
        # puts :TINY if y_range.size == 1
      else
        raise "Edge not orthogonal: #{a.inspect}--#{b.inspect}" unless a.y == b.y
      end
    end

    @vertical_edges.sort_by!(&:x)
    # TODO: what if the polygon overlaps itself?!
    pp self if $DEBUG
  end

  # inclusive range
  def point_at_range(p, r)
    if p == r.begin
      if p == r.end
        :both
      else
        :begin
      end
    elsif p == r.end
      :end
    else
      # r.cover?(p)
      # our ranges are only the covering ones
      # true
      nil
    end
  end

  # corners and border does count as inside
  def inside?(point)
    @inside_cache ||= {}
    return @inside_cache[point] if @inside_cache.has_key?(point)

    x, y = point.x, point.y

    # Cast a ray from `point` to the left
    # and count the times it intersects the vertical edges
    y_intersecting = @vertical_edges.find_all { |e| e.y_range.cover?(y) }

    # the ray starts at -Inf, outside the polygon
    v_edges_seen = 0
    # the point lies AT a vertical edge; same x coord
    last_at_v_edge = false

    # nil
    # but if the ray is going along a horizontal edge:
    # :begin, :end - having entered it at the begin/end of a vertical edge
    # :both - the vertical edge is just a single tile with begin == end
    at_h_edge = nil

    y_intersecting.each do |e|
      if e.x > x
        # the ray has flown past the target point
        inside = last_at_v_edge || v_edges_seen.odd? || !!at_h_edge
        puts "  #{inside ? 'IN ' : 'OUT'} #{point.inspect}" if $DEBUG
        @inside_cache[point] = inside
        return inside
      else
        v_edges_seen += 1
        last_at_v_edge = e.x == x

        y_range = e.y_range
        par = point_at_range(y, y_range)
        case par
        when true, false, nil
          # clean crossing of an edge
          at_h_edge = nil
        when :begin
          case at_h_edge
          when nil
            at_h_edge = :begin
          when :begin
            at_h_edge = nil
          when :end
            v_edges_seen -= 1
            at_h_edge = nil
          end
        when :end
          case at_h_edge
          when nil
            at_h_edge = :end
          when :end
            at_h_edge = nil
          when :begin
            v_edges_seen -= 1
            at_h_edge = nil
          end
        when :both
          raise "should not happen in our data and I am lazy"
        end
      end
    end

    raise unless v_edges_seen.even?
    inside = last_at_v_edge

    puts "  #{inside ? 'IN ' : 'OUT'} #{point.inspect}" if $DEBUG
    @inside_cache[point] = inside
    inside
  end

  def classify(point)
    i = inside?(point)
    return " " if i.nil?
    return "." if i == false
    return "@" if i == true

    i.to_s[0]
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

  def dump
    old_debug = $DEBUG
    $DEBUG = nil

    xmin, xmax = @points.map(&:x).minmax
    ymin, ymax = @points.map(&:y).minmax

    (ymin-1..ymax+1).each do |y|
      (xmin-1..xmax+1).each do |x|
        print classify(Point.new(x, y))
      end
      puts
    end
    $DEBUG = old_debug
  end
end

MUTATIONS = [
  ->(p) { Point.new(p.x, p.y) },
  ->(p) { Point.new(-p.x, p.y) },
  ->(p) { Point.new(p.x, -p.y) },
  ->(p) { Point.new(-p.x, -p.y) },
  ->(p) { Point.new(p.y, p.x) },
  ->(p) { Point.new(-p.y, p.x) },
  ->(p) { Point.new(p.y, -p.x) },
  ->(p) { Point.new(-p.y, -p.x) },
].freeze

def mutated_floors(points)
  MUTATIONS.map do |m|
    ps = points.map { |p| m.call(p) }
    Floor.new(ps)
  end
end

if $PROGRAM_NAME == __FILE__
  ps = Floor.points_from_file(ARGV[0] || "input.txt")
  fl = Floor.new(ps)
  puts "Maximal red rectangle: #{fl.max_red_area}"

  mutated_floors(ps).each do |f|
    f.dump if ARGV[0] == "sample.txt"
    puts "Maximal red rectangle within green area: #{f.max_red_area_within_green}"
  end
end
