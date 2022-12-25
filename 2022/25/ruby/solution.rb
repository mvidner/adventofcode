#!/usr/bin/env ruby

# Balanced Quinary numeral system
class Snafu
  def self.top_base(n)
    raise if n < 0
    return 1 if n == 0

    top_base = Math.log(n, 5).ceil
    top_half = 5 ** top_base / 2.0
    top_base += 1 if n > top_half
    top_base
  end

  def self.from_i(n)
    base = top_base(n)

    bias = (5 ** base) / 2
    quinary = (n + bias).to_s(5)
    s = quinary.tr("10234", "-=012")

    new(s)
  end

  def to_s
    @string
  end

  def to_i
    quinary = @string.tr("-=012", "10234")
    base = @string.size
    bias = (5 ** base) / 2
    quinary.to_i(5) - bias
  end

  def initialize(string)
    @string = string
  end
end

if $PROGRAM_NAME == __FILE__
  if false
    t = (0..27).map do |n|
      [n, Snafu.top_base(n), Snafu.from_i(n), Snafu.from_i(n).to_i]
    end
    pp t
  end

  text = File.read(ARGV[0] || "input.txt")
  lines = text.lines.map(&:chomp)

  sum = lines.map { |line| Snafu.new(line).to_i }.sum
  puts "Sum: #{sum}"
  puts "Snafu Sum: #{Snafu.from_i(sum)}"
end
