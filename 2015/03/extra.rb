#!/usr/bin/ruby
require "set"

STEPS = {
  "^" => [ 0,  1],
  ">" => [ 1,  0],
  "v" => [ 0, -1],
  "<" => [-1,  0]
}

input = File.read("input").strip.split(//)

visited = Set.new

# @param visited a set of houses ([x,y])
# @param steps character codes
# updates *visited*
def santa_run(visited, steps)
  position = [0, 0]
  visited.add(position)

  steps.each do |step|
    delta = STEPS[step]
    position = [position.first + delta.first, position.last + delta.last]
    visited.add(position)
  end
end

santa_steps = []
robosanta_steps = []
input.each_slice(2) do |s, r|
  santa_steps << s
  robosanta_steps << r
end

santa_run(visited, santa_steps)
santa_run(visited, robosanta_steps)

puts visited.size
