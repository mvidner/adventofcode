#!/usr/bin/env ruby

digits = File.read("input.txt").chomp
array = digits.chars.map(&:to_i)

sum = 0
array.each_cons(2) do |a, b|
  sum += a if a == b
end
sum += array[0] if array[0] == array[-1]
puts sum

sum2 = 0
half = array.size / 2
(0 .. half - 1).each do |i|
  sum2 += array[i] if array[i] == array[i + half]
end
puts sum2 * 2
