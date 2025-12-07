#!/usr/bin/env ruby
text = File.read(ARGV[0] || "input.txt")

joltages = text.lines.map do |l|
  nums = l.chomp.chars.map(&:to_i)
  # max_by returns all maximums, we take the first one
  first, where = nums[0..-2].each_with_index.to_a.max_by { |n, _i| n }
  second = nums[where + 1..-1].max
  10 * first + second
end

puts "Joltages sum #{joltages.sum}"
