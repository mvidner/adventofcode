#!/usr/bin/env ruby

def satisfied_a(t)
  # optimized this by hand on paper, which turned to take much more time
  t % 13 == 2 &&
    t % 17 == 0 &&
    t % 19 == 18 &&
    t % 7 == 2 &&
    t % 5 == 0 &&
    t % 3 == 2
end

def satisfied_b(t)
  satisfied_a(t) &&
    (t + 7 + 0) % 11 == 0
end

puts "Part A:"
puts 1.upto(Float::INFINITY).find {|t| satisfied_a(t)}

puts "Part B:"
puts 1.upto(Float::INFINITY).find {|t| satisfied_b(t)}
