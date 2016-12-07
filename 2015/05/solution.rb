#!/usr/bin/ruby
input = File.read("input").split(/\n/).map(&:chomp)

def nice?(s)
  three_wovels?(s) && double_letter?(s) && !banned_pair?(s)
end

def three_wovels?(s)
  s.count("aeiou") >= 3
end

def double_letter?(s)
  s =~ /(.)\1/
end

def banned_pair?(s)
  s =~ /(ab|cd|pq|xy)/
end

puts input.count {|s| nice?(s) }
