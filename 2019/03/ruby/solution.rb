#!/usr/bin/env ruby
require "set"

def crossing_distance(directions_s)
  lines = directions_s.split "\n"
  wire1 = plot(lines[0])
  wire2 = plot(lines[1])

  crossings = Set.new(wire1.keys).intersection(Set.new(wire2.keys))
  crossing_distances = crossings.map do |point|
    point[0].abs + point[1].abs
  end
  # the 1st element [0] is [0,0] but we want the nontrivial solution
  crossing_distances.sort[1]
end

def crossing_steps(directions_s)
  lines = directions_s.split "\n"
  wire1 = plot(lines[0])
  wire2 = plot(lines[1])

  crossings = Set.new(wire1.keys).intersection(Set.new(wire2.keys))
  crossing_steps = crossings.map do |point|
    wire1[point] + wire2[point]
  end
  # the 1st element [0] is [0,0] but we want the nontrivial solution
  crossing_steps.sort[1]
end

# We represent a wire by a {Hash}:
# the keys are the grid points which it passes through.
# (A point is simply a pair of [x, y] coordinates)
# The values are the number of steps required to reach that point
def plot(dirs)
  steps = 0
  pos = [0, 0]
  wire = {}
  wire[pos.dup] ||= steps

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
      steps += 1
      pos[0] += delta[0]
      pos[1] += delta[1]
      wire[pos.dup] ||= steps
    end
  end

  wire
end

if $0 == __FILE__
  input = File.read("input.txt")
  puts "Part 1"
  puts crossing_distance(input)
  puts "Part 2"
  puts crossing_steps(input)
end
