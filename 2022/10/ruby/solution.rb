#!/usr/bin/ruby

class CRT
  attr_reader :nrows

  attr_reader :ncols

  attr_reader :pixels

  def initialize(nrows:, ncols:)
    @nrows = nrows
    @ncols = ncols

    @pixels = " " * (nrows * ncols)
  end

  def to_s
    @nrows.times.map do |r|
      @pixels[r * @ncols, @ncols]
    end.join("\n") + "\n"
  end

  # clock is 1 based but pixels are 0 based
  def draw(clock, sprite_pos)
    column = (clock - 1) % @ncols
    if (sprite_pos - 1 .. sprite_pos + 1).cover?(column)
      pix = "#"
    else
      pix = "."
    end
    @pixels[clock - 1] = pix
  end
end

class SignalProbe
  attr_reader :strengths_sum

  def initialize
    @important_cycles = [20, 60, 100, 140, 180, 220]
    @strengths_sum  = 0
  end

  def probe(cycles, x)
    return unless cycles == @important_cycles.first

    @important_cycles.shift
    strength = cycles * x
    # puts "#{cycles} * #{x} = #{strength}"
    @strengths_sum += strength
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
    # puts "  (#{cycles}: #{x}) #{insn}"

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
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  input = text.lines.map(&:chomp)

  cpu = CPU.new
  probe = SignalProbe.new
  crt = CRT.new(nrows: 6, ncols: 40)

  input.each do |insn|
    cpu.do1(insn) do |cycles, x|
      probe.probe(cycles, x)
      crt.draw(cycles, x)
    end
  end

  puts probe.strengths_sum
  puts crt
end
