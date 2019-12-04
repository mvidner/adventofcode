#!/usr/bin/env ruby
require "set"

def crossing_distance(directions_s)
  lines = directions_s.split "\n"
  wire1 = plot(lines[0])
  wire2 = plot(lines[1])

  crossings = wire1.intersection(wire2)
  crossing_distances = crossings.map do |point|
    point[0].abs + point[1].abs
  end
  # the 1st element [0] is [0,0] but we want the nontrivial solution
  crossing_distances.sort[1]
end

# We represent a wire by a {Set} of grid points which it passes through.
# A point is simply a pair of [x, y] coordinates
def plot(dirs)
  pos = [0, 0]
  wire = Set.new
  wire << pos.dup

  dirs.split(",").each do |dir|
    case dir[0]
    when "U"
      delta = [0, 1]
    when "D"
      delta = [0, -1]
    when "L"
      delta = [-1, 0]
    when "R"
      delta = [1, 0]
    else
      raise "Unrecognized instruction #{dir}"
    end

    count = Integer(dir[1..-1])
    count.times do
      pos[0] += delta[0]
      pos[1] += delta[1]
      wire << pos.dup
    end
  end

  wire
end

if $0 == __FILE__
  puts crossing_distance(File.read("input.txt"))
end
