#!/usr/bin/ruby
require "set"

input = File.read("input").strip.split(//)

position = [0, 0]
visited = [position].to_set

steps = {
  "^" => [ 0,  1],
  ">" => [ 1,  0],
  "v" => [ 0, -1],
  "<" => [-1,  0]
}

input.each do |step|
  delta = steps[step]
  position = [position.first + delta.first, position.last + delta.last]
  visited.add(position)
end

puts visited.size
