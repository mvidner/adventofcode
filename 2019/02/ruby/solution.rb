#!/usr/bin/env ruby
# memory
m = File.read("input.txt").split(",").map { |s| Integer(s) }
# "1202 program alarm"
m[1] = 12
m[2] = 2

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

puts m[0]
