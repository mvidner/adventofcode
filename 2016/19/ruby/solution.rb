#!/usr/bin/env ruby

def white_elephant_party(n)
  elves = Array.new(n, 1)

  left = n
  i = 0
  loop do
    victim = next_elf(elves, i)
    break if victim == i

    elves[i] += elves[victim]
    elves[victim] = 0
    i = next_elf(elves, victim)
  end

  i + 1
end

def next_elf(elves, i)
  n = elves.size
  begin
    i  = (i + 1) % n
  end until elves[i] > 0
  i
end

puts "Example:"
puts white_elephant_party(5)

puts "Solution:"
puts white_elephant_party(3014603)
