#!/usr/bin/ruby
require "set"

def start_of_signal(string, count = 4)
  chars = string.chars
  chars.each_cons(count).each_with_index do |cons, i|
    return i+count if Set.new(cons).size == count
  end
end

text = File.read(ARGV[0] || "input.txt")
puts start_of_signal(text)
puts start_of_signal(text, 14)
