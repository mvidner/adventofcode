#!/usr/bin/ruby

text = File.read(ARGV[0] || "input.txt")
data = text.lines.map(&:chomp)

# (Considering only inclusive ranges)
# Ruby 2.5 always returns false for Range.cover?(Range)
def range_cover?(outer, inner)
  outer.cover?(inner.begin) && outer.cover?(inner.end)
end

contained = data.find_all do |line|
  as, bs = line.split /,/
  ar = Range.new(* as.split(/-/))
  br = Range.new(* bs.split(/-/))

  range_cover?(ar, br) || range_cover?(br, ar)
end

puts "Pairs with containment: #{contained.size}"
