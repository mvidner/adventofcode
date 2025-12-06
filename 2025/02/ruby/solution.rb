#!/usr/bin/env ruby
text = File.read(ARGV[0] || "input.txt")

data = text.split(",").map do |item|
  from, to = item.split("-")
  # inclusive Range
  (from.to_i..to.to_i)
end

def invalid_id?(integer)
  s = integer.to_s
  s =~ /\A(\d+)\1\Z/
end

# stupid iteration
def sum_invalid_ids(range)
  range.map { |i| invalid_id?(i) ? i : 0 }.sum
end

total_invalid_ids = data.map { |r| sum_invalid_ids(r) }.sum

puts "Sum of invalid ids: #{total_invalid_ids}"
