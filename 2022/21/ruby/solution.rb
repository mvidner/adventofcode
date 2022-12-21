#!/usr/bin/env ruby

# value is nil or Numeric, others are String
Monkey = Struct.new(:name, :value, :left, :op, :right)

class Monkeys
  attr_reader :monkeys

  def initialize(lines)
    @monkeys = lines.map do |line|
      line =~ /^([a-z]+): (.*)/ or raise "Bad monkey name '#{line}'"
      name = $1
      rest = $2

      if rest =~ /(-?\d+)/
        value = $1.to_i
        left = op = right = nil
      elsif rest =~ /([a-z]+) ([+*\/-]) ([a-z]+)/
        value = nil
        left, op, right = $1, $2, $3
      else
        raise "Bad monkey job description '#{rest}'"
      end

      [name, Monkey.new(name, value, left, op, right)]
    end.to_h
  end

  def compute(a, op, b)
    case op
    when "+"
      a + b
    when "-"
      a - b
    when "*"
      a * b
    when "/"
      a / b
    else
      raise ArgumentError
    end
  end

  def value(monkey_name)
    m = monkeys[monkey_name]
    v = m.value
    if v.nil?
      l = value(m.left)
      r = value(m.right)
      v = compute(l, m.op, r)
      m.value = v
    end
    v
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")

  ms = Monkeys.new(text.lines)
  puts ms.monkeys.size
  puts ms.value("root")
end
