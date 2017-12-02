#!/usr/bin/env ruby
lines = File.readlines("input.txt")

diffs = lines.map do |line|
  nums = line.split.map(&:to_i)
  nums.max - nums.min
end

checksum = diffs.reduce(0, :+)
puts checksum

# a divides b
def divides?(a, b)
  return false if a == 0
  b % a == 0 && b / a != 1
end
  
ratios = lines.map do |line|
  nums = line.split.map(&:to_i)
  ratio = nil
  (0 .. nums.size - 1).each do |a|
    (0 .. nums.size - 1).each do |b|
      ratio = nums[b] / nums[a] if divides?(nums[a], nums[b])
    end
  end
  ratio
end

checksum2 = ratios.reduce(0, :+)
puts checksum2
