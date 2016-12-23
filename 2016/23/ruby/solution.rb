#!/usr/bin/env ruby

# instruction internal representation is a tuple
# (opcode, arg1_is_register, arg1_num, arg2_is_register, arg2_num)
#
# arg2_* may be nil

A_ORD = "a".ord

def parse_arg(arg)
  if ("a" .. "d").cover?(arg[0])
    [true, arg.ord - A_ORD]
  else
    [false, arg.to_i]
  end
end

def parse(string_instr)
  case string_instr
  when /inc (\S+)/
    [:inc, * parse_arg($1), nil, nil]
  when /dec (\S+)/
    [:dec, * parse_arg($1), nil, nil]
  when /tgl (\S+)/
    [:tgl, * parse_arg($1), nil, nil]
  when /cpy (\S+) (\S+)/
    [:cpy, * parse_arg($1), * parse_arg($2)]
  when /jnz (\S+) (\S+)/
    [:jnz, * parse_arg($1), * parse_arg($2)]
  else
    raise "Cannot parse instruction '#{string_instr}"
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
    case instr[0]
    when :inc
      r = instr[2]
      regarr[r] += 1
    when :dec
      r = instr[2]
      regarr[r] -= 1

    when :cpy
      _opcode, src_isreg, src_num, dest_isreg, dest_num = * instr
      if dest_isreg
        regarr[dest_num] = src_isreg ? regarr[src_num] : src_num
      else
        # invalid instruction, skip it
      end

    when :jnz
      _opcode, cond_isreg, cond_num, displ_isreg, displ_num = * instr
      if (cond_isreg ? regarr[cond_num] : cond_num) != 0
        ip += (displ_isreg ? regarr[displ_num] : displ_num) - 1
      end

    when :tgl
      addr = ip - 1 + (instr[1] ? regarr[instr[2]] : instr[2])
      next unless (0...instrs.size).cover?(addr)
      opcode = {
        inc: :dec,
        dec: :inc,
        tgl: :inc,
        cpy: :jnz,
        jnz: :cpy
      }.fetch(instrs[addr][0])
      # make a new instruction
      instrs[addr] = [opcode] + instrs[addr][1..-1]
    else
      raise "Unknown instruction #{instr}"
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

instrs = File.readlines("input.txt").map { |i| parse(i) }

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
