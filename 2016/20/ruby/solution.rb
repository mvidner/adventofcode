#!/usr/bin/env ruby
require "bitarray"

allowed = BitArray.new(2 ** 32)

File.readlines("input.txt").each_with_index do |line, i|
  line =~ /(\d+)-(\d+)/
  low = $1.to_i
  high = $2.to_i
  raise "Invalid range input" if high < low
  puts "#{i}: #{high-low} #{line}"
  (low .. high).each { |a| allowed[a] = 0 }
end

puts "Solution:"
puts (0 ... 2 ** 32).find { |i| allowed[i] == 1 }
