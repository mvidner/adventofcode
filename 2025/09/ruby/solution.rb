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
end

class Floor
  def self.from_file(filename)
    text = File.read(filename)
    points = text.lines.map do |line|
      x, y = line.split(",").map(&:to_i)
      Point.new(x, y)
    end
    new(points)
  end

  def initialize(points)
    @points = points
  end

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
end

if $PROGRAM_NAME == __FILE__
  f = Floor.from_file(ARGV[0] || "input.txt")
  
  puts "Maximal red rectangle: #{f.max_red_area}"
end
