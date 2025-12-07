#!/usr/bin/env ruby
text = File.read(ARGV[0] || "input.txt")

def joltage_nums(nums, size)
  return [nums.max] if size == 1

  first, where = nums[0..-size].each_with_index.to_a.max_by { |n, _i| n }
  rest = joltage_nums(nums[where + 1..-1], size - 1)
  [first, *rest]
end

def joltage(nums, size)
  joltage_nums(nums, size).map(&:to_s).join.to_i
end

all_nums = text.lines.map do |l|
  l.chomp.chars.map(&:to_i)
end

joltages = all_nums.map do |nums|
  joltage(nums, 2)
end
puts "Joltages sum #{joltages.sum}"

large_joltages = all_nums.map do |nums|
  joltage(nums, 12)
end
puts "Large joltages sum #{large_joltages.sum}"
