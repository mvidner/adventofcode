#!/usr/bin/ruby

class CRT
  def initialize
    @pixels = " " * 240
  end

  def dump
    6.times do |row|
      puts @pixels[row*40, 40]
    end
  end

  # clock is 1 based but pixels are 0 based
  def draw(clock, sprite_pos)
    column = (clock - 1) % 40
    if (sprite_pos - 1 .. sprite_pos + 1).cover?(column)
      pix = "#"
    else
      pix = "."
    end
    @pixels[clock - 1] = pix
  end
end

class CPU
  attr_accessor :x

  # already elapsed
  attr_accessor :cycles

  def initialize
    @x = 1
    @cycles = 0
  end

  def do1(insn)
    @cycles += 1
    yield cycles, x

    case insn
    when "noop"
      # nothing
    when /addx (-?\d+)/
      # second cycle: check _during_ it
      @cycles += 1
      yield cycles, x

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
  cpu = CPU.new
  input.each do |insn|
    # puts "  (#{crt.cycles}: #{crt.x}) #{insn}"
    cpu.do1(insn) do |cycles, x|
      crt.draw(cycles, x)
    end
  end

  crt.dump
end
