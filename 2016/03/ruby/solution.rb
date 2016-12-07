#!/usr/bin/env ruby

triangles = File.readlines("input.txt").map do |line|
  line.split.map(&:to_i)
end

def is_triangle?(t)
  t[0] < t[1] + t[2] &&
    t[1] < t[0] + t[2] &&
    t[2] < t[0] + t[1]
end

puts "Solution:"
puts triangles.count{|t| is_triangle?(t)}

puts "Bonus:"
vtriangles = triangles.each_slice(3).map do |matrix3by3|
  matrix3by3.transpose
end.reduce([]) do |memo, e|
  memo.concat(e)
end
puts vtriangles.count{|t| is_triangle?(t)}
