#!/usr/bin/env ruby

class Packet
  include Comparable

  attr_reader :value

  def self.parse(s)
    val = eval(s)
    new(val)
  end

  def initialize(val)
    @value = val
  end

  def <=>(other)
    a, b = @value, other.value
    # puts "<=> #{a.inspect} #{b.inspect}"
    cmp2(a, b)
  end

  def cmp2(a, b)
    # puts "CMP2 #{a.inspect} #{b.inspect}"
    if a.nil?
      raise if b.nil?
      return -1
    end
    return 1 if b.nil?

    if a.is_a?(Integer) && b.is_a?(Integer)
      a <=> b
    else
      a = Array(a)
      b = Array(b)
      size = [a.size, b.size].max
      size.times do |i|
        ret = cmp2(a[i], b[i])
        return ret if ret != 0
      end
      0
    end
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  pairs = text.split("\n\n")
  packets = pairs.map do |pair_text|
    pair_text.split("\n").map { |l| Packet.parse(l) }
  end

  sum_ok = 0
  packets.each_with_index do |pair, i|
    a, b = pair
    #puts "#{a.inspect} <=> #{b.inspect}"
    #puts "  #{a <=> b}"
    if a < b
      sum_ok += i + 1
    else
      0
    end
  end
  puts sum_ok

  puts "Part 2"

  packets = text.gsub("\n\n", "\n").split("\n").map { |l| Packet.parse(l) }
  # pp packets
  # puts "GO"

  div1 = Packet.new([[2]])
  div2 = Packet.new([[6]])
  packets << div1
  packets << div2
  # puts "check:"
  # p packets[-1]

  packets.sort!
  i1 = packets.index(div1) + 1
  i2 = packets.index(div2) + 1
  puts "KEY #{i1*i2}"
end
