#!/usr/bin/ruby

class CRT
  attr_accessor :x

  # already elapsed
  attr_accessor :cycles

  attr_reader :strengths_sum

  def initialize
    @x = 1
    @cycles = 0
    @important_cycles = [20, 60, 100, 140, 180, 220]
    @strengths_sum  = 0
  end

  def do1(insn)
    @cycles += 1
    cycle_check

    case insn
    when "noop"
      # nothing
    when /addx (-?\d+)/
      # second cycle: check _during_ it
      @cycles += 1
      cycle_check

      # ... add only at its end
      @x += $1.to_i
    else
      raise insn
    end
  end

  def cycle_check
    return unless cycles == @important_cycles.first

    @important_cycles.shift
    strength = cycles * x
    puts "#{cycles} * #{x} = #{strength}"
    @strengths_sum += strength
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  input = text.lines.map(&:chomp)

  crt = CRT.new
  input.each do |insn|
    puts "  (#{crt.cycles}: #{crt.x}) #{insn}"
    crt.do1(insn)
  end

  puts crt.strengths_sum
end
