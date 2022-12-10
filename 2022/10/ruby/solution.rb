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
    case insn
    when "noop"
      @cycles += 1
    when /addx (-?\d+)/
      n = $1.to_i
      @x += n
      @cycles += 2
    else
      raise insn
    end

    cycle_check
  end

  def cycle_check
    # round down
    c = cycles & ~1
    return unless c == @important_cycles.first

    @important_cycles.shift
    strength = c * x
    puts "#{c} * #{x} = #{strength}"
    @strengths_sum += strength
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  input = text.lines.map(&:chomp)

  crt = CRT.new
  input.each do |insn|
    crt.do1(insn)
  end

  puts crt.strengths_sum
end
