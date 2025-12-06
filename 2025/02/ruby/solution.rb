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

def better_invalid_id?(integer)
  s = integer.to_s
  s =~ /\A(\d+)\1+\Z/
end

# stupid iteration
def sum_invalid_ids(data, invalid_method)
  data.map do |range|
    range.map { |i| __send__(invalid_method, i) ? i : 0 }.sum
  end.sum
end

total_invalid_ids = sum_invalid_ids(data, :invalid_id?)
puts "Sum of invalid ids: #{total_invalid_ids}"

better_total_invalid_ids = sum_invalid_ids(data, :better_invalid_id?)
puts "Better sum of invalid ids: #{better_total_invalid_ids}"
