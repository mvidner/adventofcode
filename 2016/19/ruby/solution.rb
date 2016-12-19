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

def next_elf_across(elves, i, left)
  (left / 2).times do
    i = next_elf(elves, i)
  end
  i
end

def white_elephant_party_two(n)
  # this time, elves is the array of the remaining elves, with their
  # original numbers as values
  elves = 1.upto(n).to_a

  i = 0
  while elves.size > 1
    n = elves.size
    puts n if 0 == n % 10000
    i = i % n
    victim = (i + (n / 2)) % n
#    puts "@#{i}'s turn, the victim is @#{victim}"
#    p elves
    elves.delete_at(victim)
    i += 1 if victim > i
  end

  elves.first
end


puts "Example:"
puts white_elephant_party(5)

puts "Solution:"
#puts white_elephant_party(3014603)

puts "Example part two:"
puts white_elephant_party_two(5)

puts "Solution part two:"
puts white_elephant_party_two(3014603)
