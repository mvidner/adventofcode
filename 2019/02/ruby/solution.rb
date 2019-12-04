#!/usr/bin/env ruby
# memory
m = File.read("input.txt").split(",").map { |s| Integer(s) }
m.freeze

def compute(m, noun, verb)
  m = m.dup

  m[1] = noun
  m[2] = verb

  ip = 0
  loop do
    case m[ip]
    when 1
      m[m[ip + 3]] = m[m[ip + 1]] + m[m[ip + 2]]
    when 2
      m[m[ip + 3]] = m[m[ip + 1]] * m[m[ip + 2]]
    when 99
      break
    else
      raise "Unexpected opcode #{m[ip].inspect} at position #{ip}"
    end

    ip += 4
  end

  m[0]
end

puts "Part 1"
# "1202 program alarm"
puts compute(m, 12, 2)

puts "Part 2"
(0..99).each do |noun|
  (0..99).each do |verb|
    if compute(m, noun, verb) == 19690720
      puts 100 * noun + verb
      exit
    end
  end
end
