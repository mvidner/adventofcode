#!/usr/bin/env ruby

A_ORD = "a".ord

# @param regarr [Array] *a* at 0, *d* at 3
def decode(arg, regarr)
  if ("a" .. "d").cover?(arg[0])
    regarr[arg.ord - A_ORD]
  else
    arg.to_i
  end
end

# @param regarr [Array] initial register values
# @return [Array] final register values
def run(instrs, regarr)
  regarr = regarr.dup               # do not mutate the argument
  instrs = instrs.dup           # do not mutate the original instructions either
  timer = 0
  ip = 0

  loop do
    instr = instrs[ip]
    ip += 1
    timer += 1
    puts "#{ip}: #{regarr}; #{timer}" if 0 == timer % 1000000
    break if instr.nil?
    case instr
    when /inc ([a-d])/
      r = $1.ord - A_ORD
      regarr[r] += 1
    when /dec ([a-d])/
      r = $1.ord - A_ORD
      regarr[r] -= 1

    when /cpy ([a-d0-9-]+) ([a-d])/
      val  = decode($1, regarr)
      dest = $2.ord - A_ORD
      regarr[dest] = val

    when /cpy ([a-d0-9-]+) ([0-9-]+)/
      # invalid instruction, skip it

    when /jnz ([a-d0-9-]+) ([a-d0-9-]+)/
      cond = decode($1, regarr)
      displacement = decode($2, regarr)
      if cond != 0
        ip += displacement - 1
      end

    when /tgl ([a-d])/
      displacement = regarr[$1.ord - A_ORD]
      addr = ip - 1 + displacement
      next unless (0...instrs.size).cover?(addr)
      opcode = {
        "inc" => "dec", "dec" => "inc", "tgl" => "inc",
        "cpy" => "jnz", "jnz" => "cpy"
      }.fetch(instrs[addr][0..2])
      # make a new string, do not mutate the original string
      instrs[addr] = opcode + instrs[addr][3..-1]
    else
      raise "#{instr}: #{ip}: #{regarr}"
    end
  end

  regarr
end

def time_it
  t0 = Time.now
  yield
  t1 = Time.now
  printf("It took %.4g seconds.\n", t1 - t0)
end

instrs = File.readlines("input.txt").map(&:chomp)

regarr = [7, 0, 0, 0]

p instrs
time_it do
  puts "Solution to part A:"
  aregs = run(instrs, regarr)
  puts aregs[0]
end

puts
time_it do
  regarr[0] = 12
  puts "Solution to part B:"
  bregs = run(instrs, regarr)
  puts bregs[0]
end
