#!/usr/bin/env ruby

blocked = File.readlines("input.txt").map do |line|
  line =~ /(\d+)-(\d+)/
  low = $1.to_i
  high = $2.to_i
  raise "Invalid range input" if high < low
  [low, high]
end
blocked.sort!
blocked << [2 ** 32, 2 ** 32]   # sentinel value

puts "Solution:"
first_allowed = 0
blocked.each do |low, high|
  if high < first_allowed
    next
  elsif (low .. high).member?(first_allowed)
    first_allowed = high + 1
  else
    break
  end
end
puts first_allowed

puts "Part two:"
first_allowed = 0
allowed_count = 0
blocked.each do |low, high|
  # invariant: allowed_count <= limit <= low <= high
  if high < first_allowed
    next
  elsif (low .. high).member?(first_allowed)
    first_allowed = high + 1
  else # first_allowed < low
    allowed_count += low - first_allowed
    first_allowed = high + 1
  end
end
puts allowed_count
