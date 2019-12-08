#!/usr/bin/env ruby
input = File.read("input.txt").chomp

W = 25
H = 6
isize = input.size
lsize =  W * H

nlayers = isize / lsize

min0layer = (0...nlayers).map do |i|
  layer = input[i * W * H, W * H]
  [i, layer.count("0")]
end.min_by { |i, count| count }.first

puts min0layer
layer = input[min0layer * W * H, W * H]
puts layer.count("1") * layer.count("2")
