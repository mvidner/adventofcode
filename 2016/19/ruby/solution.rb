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

  empty = 0
  empty2 = 0
  i = 0
  while n > 1
    i = i % n
    victim = (i + (n / 2)) % n
    if 0 == n % 10000
      puts "N #{n}, I #{i}, V #{victim}"
    end
#    puts "@#{i}'s turn, the victim is @#{victim}"
#    p elves
    if victim > i
      if empty2 > 0
        elves.compact!
        empty2 = 0
      end
      elves[victim + empty] = nil
      empty += 1
      i += 1
      n -= 1
    else
      if empty > 0
        elves.compact!
        empty = 0
      end
      elves[victim + empty2] = nil
      empty2 += 1
      n -= 1
    end
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
