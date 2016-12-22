#!/usr/bin/env ruby

blocked = File.readlines("input.txt").map do |line|
  line =~ /(\d+)-(\d+)/
  low = $1.to_i
  high = $2.to_i
  raise "Invalid range input" if high < low
  [low, high]
end

puts "Solution:"
first_allowed = 0
blocked.sort.each do |low, high|
  if high < first_allowed
    next
  elsif (low .. high).member?(first_allowed)
    first_allowed = high + 1
  else
    break
  end
end
puts first_allowed
