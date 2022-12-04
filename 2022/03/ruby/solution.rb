#!/usr/bin/env ruby
require "set"

text = File.read(ARGV[0] || "input.txt")
data = text.lines

def priority(letter)
  if ("a".."z").include?(letter)
    letter.ord - "a".ord + 1
  elsif ("A".."Z").include?(letter)
    letter.ord - "A".ord + 27
  else
    raise
  end
end

priorities = data.map do |rucksack|
  rucksack = rucksack.chomp
  len = rucksack.length
  first = rucksack[0, len/2]
  second = rucksack[len/2, len/2]

  first_set = Set.new(first.split(//))
  second_set = Set.new(second.split(//))
  both = first_set.intersection(second_set)
  raise unless both.size == 1

  priority(both.first)
end

puts "Sum of priorities: #{priorities.sum}"
