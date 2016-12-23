#!/usr/bin/env ruby

def decode(arg, regs)
  if ("a" .. "d").cover?(arg[0])
    regs[arg.to_sym]
  else
    arg.to_i
  end
end

# @param regs [Hash] initial register values
# @return [Hash] final register values
def run(instrs, regs)
  regs = regs.dup               # do not mutate the argument
  instrs = instrs.dup           # do not mutate the original instructions either
  timer = 0
  ip = 0

  loop do
    instr = instrs[ip]
    ip += 1
    timer += 1
    puts "#{ip}: #{regs}; #{timer}" if 0 == timer % 1000000
    break if instr.nil?
    case instr
    when /inc ([a-d])/
      r = $1.to_sym
      regs[r] += 1
    when /dec ([a-d])/
      r = $1.to_sym
      regs[r] -= 1

    when /cpy ([a-d0-9-]+) ([a-d])/
      val  = decode($1, regs)
      dest = $2.to_sym
      regs[dest] = val

    when /cpy ([a-d0-9-]+) ([0-9-]+)/
      # invalid instruction, skip it

    when /jnz ([a-d0-9-]+) ([a-d0-9-]+)/
      cond = decode($1, regs)
      displacement = decode($2, regs)
      if cond != 0
        ip += displacement - 1
      end

    when /tgl ([a-d])/
      displacement = regs[$1.to_sym]
      addr = ip - 1 + displacement
      next unless (0...instrs.size).cover?(addr)
      opcode = {
        "inc" => "dec", "dec" => "inc", "tgl" => "inc",
        "cpy" => "jnz", "jnz" => "cpy"
      }.fetch(instrs[addr][0..2])
      # make a new string, do not mutate the original string
      instrs[addr] = opcode + instrs[addr][3..-1]
    else
      raise "#{instr}: #{ip}: #{regs}"
    end
  end

  regs
end

def time_it
  t0 = Time.now
  yield
  t1 = Time.now
  printf("It took %.4g seconds.\n", t1 - t0)
end

instrs = File.readlines("input.txt").map(&:chomp)

regs = {}
regs[:a] = regs[:b] = regs[:c] = regs[:d] = 0
regs[:a] = 7

p instrs
time_it do
  puts "Solution to part A:"
  aregs = run(instrs, regs)
  puts aregs[:a]
end

puts
time_it do
  regs[:a] = 12
p instrs, regs
  puts "Solution to part B:"
  bregs = run(instrs, regs)
  puts bregs[:a]
end
