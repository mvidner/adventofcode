#!/usr/bin/env ruby

require "pp"

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

def dump(label, instrs)
  puts label
  return
  pp instrs
end

# may mutate instrs
def post_optimize_jnz!(instrs, ip)
  opcode, _cond_isreg, _cond_num, displ_isreg, displ_num = * instrs[ip]
  raise unless opcode == :jnz

  # inc X      or   dec Y
  # dec Y           inc X
  # jnz Y, -2       jnz Y, -2
  #            ->
  # add Y, X
  # cpy_ 0, Y
  # nop
  if !displ_isreg && displ_num == -2
    dec_opcode, _, dec_reg, _, _ = * instrs[ip - 1]
    inc_opcode, _, inc_reg, _, _ = * instrs[ip - 2]
    if dec_opcode == :inc && inc_opcode == :dec
      dec_opcode, inc_opcode = :dec, :inc
      dec_reg, inc_reg = inc_reg, dec_reg
    end
    if dec_opcode == :dec && inc_opcode == :inc
      dump "BEFORE", instrs
      instrs[ip - 2] = [:add,  true, dec_reg, true, inc_reg]
      instrs[ip - 1] = [:cpy_, false, 0,      true, dec_reg]
      instrs[ip    ] = [:nop,  nil, nil, nil, nil]
      dump "AFTER", instrs
    end
  end

  # cpy X, Y
  # add Y, Z
  # (any, actually cpy 0, Y)
  # (any, actually nop)
  # dec W
  # jnz W, -5
  #   ->
  # cpy X, Y
  # mul Y, W
  # (keep)
  # (keep)
  # add W, Z
  # cpy_ 0, W
  if !displ_isreg && displ_num == -5
    cpy_opcode, _, src0_reg, _, dst0_reg = * instrs[ip - 5]
    add_opcode, _, src_reg,  _, dst_reg  = * instrs[ip - 4]
    dec_opcode, _, dec_reg,  _, _        = * instrs[ip - 1]
    if cpy_opcode == :cpy && dec_opcode == :dec && add_opcode == :add &&
        dst0_reg == src_reg
      dump "BEFORE MUL", instrs
      instrs[ip - 4] = [:mul,  true, src_reg, true, dec_reg]
      instrs[ip - 1] = [:add,  true, dec_reg, true, dst_reg]
      instrs[ip    ] = [:cpy_, false, 0,      true, dec_reg]
      dump "AFTER MUL", instrs
    end
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
    puts "#{ip}: #{regarr}; #{timer}" if 0 == timer % 1#000000

    next_ip = ip + 1
    timer += 1
    break if instr.nil?
    case instr[0]
    when :nop
      # no operation
    when :inc
      r = instr[2]
      regarr[r] += 1
    when :dec
      r = instr[2]
      regarr[r] -= 1

    when :cpy, :cpy_
      _opcode, src_isreg, src_num, dest_isreg, dest_num = * instr
      if dest_isreg
        regarr[dest_num] = src_isreg ? regarr[src_num] : src_num
      else
        # invalid instruction, skip it
      end

    when :add
      _opcode, src_isreg, src_num, dest_isreg, dest_num = * instr
      if dest_isreg
        regarr[dest_num] += src_isreg ? regarr[src_num] : src_num
      else
        # invalid instruction, skip it
      end

    when :mul
      _opcode, src_isreg, src_num, dest_isreg, dest_num = * instr
      if dest_isreg
        regarr[dest_num] *= src_isreg ? regarr[src_num] : src_num
      else
        # invalid instruction, skip it
      end

    when :jnz
      _opcode, cond_isreg, cond_num, displ_isreg, displ_num = * instr
      cond = cond_isreg ? regarr[cond_num] : cond_num
      if cond != 0
        displacement = displ_isreg ? regarr[displ_num] : displ_num
        next_ip = ip + displacement
      end
      post_optimize_jnz!(instrs, ip)

    when :tgl
      addr = ip + (instr[1] ? regarr[instr[2]] : instr[2])
      if (0...instrs.size).cover?(addr)
        # instructions produced by the optimizer cannot be toggled
        # and attempting to do so will crash the machine
        opcode = {
          inc: :dec,
          dec: :inc,
          tgl: :inc,
          cpy: :jnz,
          jnz: :cpy
        }.fetch(instrs[addr][0])
        # make a new instruction
        instrs[addr] = [opcode] + instrs[addr][1..-1]
        dump "TOGGLED", instrs
      end
    else
      raise "Unknown instruction #{instr}"
    end

    ip = next_ip
  end

  regarr
end

def time_it
  t0 = Time.now
  yield
  t1 = Time.now
  printf("It took %.4g seconds.\n", t1 - t0)
end

instrs = File.readlines(ARGV[0] || "input.txt").map { |i| parse(i) }

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
