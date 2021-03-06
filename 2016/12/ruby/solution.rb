#!/usr/bin/env ruby

# @param regs [Hash] initial register values
# @return [Hash] final register values
def run(instrs, regs)
  regs = regs.dup               # do not mutate the argument
  timer = 0
  ip = 0

  loop do
    instr = instrs[ip]
    ip += 1
    timer += 1
    puts "#{ip}: #{regs}; #{timer}" if timer % 1000000 == 0
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
        ip += $2.to_i - 1
      end
    when /jnz ([0-9]+) ([0-9-]+)/
      if $1.to_i != 0
        ip += $2.to_i - 1
      end
    else
      raise puts "#{instr}: #{ip}: #{regs}"
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

time_it do
  puts "Solution to part A:"
  aregs = run(instrs, regs)
  puts aregs[:a]
end

puts

time_it do
  regs[:c] = 1
  puts "Solution to part B:"
  bregs = run(instrs, regs)
  puts bregs[:a]
end
