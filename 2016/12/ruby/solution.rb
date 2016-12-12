#!/usr/bin/env ruby
instrs = File.readlines("input.txt")

timer = 0
ip = 0
regs = {}
regs[:a] = regs[:b] = regs[:c] = regs[:d] = 0

loop do
  instr = instrs[ip]
  ip += 1
  break if instr.nil?

  case instr
  when /inc ([a-d])/
    r = $1.to_sym
    regs[r] += 1
  when /dec ([a-d])/
    r = $1.to_sym
    regs[r] -= 1
  when /cpy (\d+) ([a-d])/
    r = $2.to_sym
    regs[r] = $1.to_i
  when /cpy ([a-d]) ([a-d])/
    src  = $1.to_sym
    dest = $2.to_sym
    regs[dest] = regs[src]
  when /jnz ([a-d]) ([0-9-]+)/
    r = $1.to_sym
    if regs[r] != 0
      ip += $2.to_i
    end
  end
end

puts "Solution to part A:"
puts regs[:a]
