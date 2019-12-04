#!/usr/bin/env ruby

DOUBLE_DIGIT = /00|11|22|33|44|55|66|77|88|99/ 
def valid_try?(n)
  return false unless (100000..999999).cover?(n)
  ns = n.to_s
  return false unless ns =~ DOUBLE_DIGIT
  ns.chars.each_cons(2) do |a, b|
    return false if a.to_i > b.to_i
  end
  true
end

DIGIT_RUNS = /0+|1+|2+|3+|4+|5+|6+|7+|8+|9+/
def more_valid_try?(n)
  runs = n.to_s.scan DIGIT_RUNS
  runs.any? { |r| r.size == 2 }
end

if $0 == __FILE__
  input = File.read("input.txt")
  min, max = input.split("-").map(&:to_i)

  puts "Part 1"
  part1 = (min..max).count do |i|
    valid_try?(i)
  end
  puts part1

  puts "Part 2"
  part2 = (min..max).count do |i|
    valid_try?(i) && more_valid_try?(i)
  end
  puts part2
end
