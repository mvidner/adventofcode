#!/usr/bin/env ruby
text = File.read("input.txt")

# list of list of integer
data = text.split("\n\n").map do |elf|
  elf.split("\n").map(&:to_i)
end

totals = data.map(&:sum)
max = totals.max
puts "Max calories: #{max}"
