#!/usr/bin/ruby

text = File.read(ARGV[0] || "input.txt")
data = text.lines.map(&:chomp)

# (Considering only inclusive ranges)
# Ruby 2.5 always returns false for Range.cover?(Range)
def range_cover?(outer, inner)
  outer.cover?(inner.begin) && outer.cover?(inner.end)
end

def range_overlap?(a, b)
  a.cover?(b.begin) || a.cover?(b.end) ||
    b.cover?(a.begin) || b.cover?(a.end)
end

ranges = data.map do |line|
  as, bs = line.split /,/
  ar = Range.new(* as.split(/-/).map(&:to_i))
  br = Range.new(* bs.split(/-/).map(&:to_i))
  [ar, br]
end

contained = ranges.find_all do |ar, br|
  range_cover?(ar, br) || range_cover?(br, ar)
end

puts "Pairs with containment: #{contained.size}"

overlapping = ranges.find_all do |ar, br|
  range_overlap?(ar, br)
end

puts "Pairs with overlap: #{overlapping.size}"
