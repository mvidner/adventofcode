#!/usr/bin/env ruby

# value is nil or Numeric, others are String
Monkey = Struct.new(:name, :value, :left, :op, :right)

class Monkeys
  attr_reader :monkeys

  def initialize(lines)
    @id_counter = 0
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

  # a and b are numbers
  def compute(a, op, b)
    case op
    when "+"
      a + b
    when "-"
      a - b
    when "*"
      a * b
    when "/"
      if a % b != 0
        Rational(a, b)
      else
        a / b
      end
    # not needed
    # when "=="
    #  a == b
    else
      raise ArgumentError
    end
  end

  def try_compute(a, op, b)
    # bail on nil(unknown) or :goal
    return nil unless a.is_a?(Numeric) && b.is_a?(Numeric)
    compute(a, op, b)
  end

  # also compute the values of all depending monkeys, if possible
  # unknown values remain nil
  def value(monkey_name)
    # p monkey_name
    m = monkeys[monkey_name]
    v = m.value
    if v.nil?
      l = value(m.left)
      r = value(m.right)
      v = try_compute(l, m.op, r)
    elsif v == :goal
      v = nil
    end
    # puts " #{monkey_name} #{v.inspect}"
    m.value = v unless v.nil?
    v
  end

  def solve(root_name)
    root = monkeys[root_name]
    raise unless root.op == "=="
    loop do
      solve_step(root)
      puts "after step"
      pp monkeys
      break if monkeys[root.left].value == :goal
    end
    puts "SOLVED"
    puts value(root.right).to_f
  end

  def new_unnamed(a, op, b)
    @id_counter += 1
    m = Monkey.new(nil, nil, a, op, b)
    m.name = "M#{@id_counter}"
    monkeys[m.name] = m
    m
  end

  # @param [Monkey]
  def solve_step(root)
    puts "solve_step (#{root.inspect})"
    l = monkeys[root.left]
    r = monkeys[root.right]
    puts "l: #{l.inspect}"
    puts "r: #{r.inspect}"

    # make *l* the unknown
    l, r = r, l if r.value.nil?

    ll = monkeys[l.left]
    lr = monkeys[l.right]
    puts "ll: #{ll.inspect}"
    puts "lr: #{lr.inspect}"

    case l.op
    when "+"
      # make ll the unknown
      ll, lr = lr, ll unless lr.value.is_a?(Numeric)

      newr = new_unnamed(r.name, "-", lr.name)
      root.right = newr.name
      root.left = ll.name
    when "*"
      # make ll the unknown
      ll, lr = lr, ll unless lr.value.is_a?(Numeric)

      newr = new_unnamed(r.name, "/", lr.name)
      root.right = newr.name
      root.left = ll.name
    when "-"
      unless ll.value.is_a?(Numeric)
        newr = new_unnamed(r.name, "+", lr.name)
        root.right = newr.name
        root.left = ll.name
      else
        newr = new_unnamed(r.name, "+", ll.name)
        root.right = newr.name
        root.left = lr.name
      end
    when "/"
      unless ll.value.is_a?(Numeric)
        newr = new_unnamed(r.name, "*", lr.name)
        root.right = newr.name
        root.left = ll.name
      else
        raise "TODO /"
      end
    end
    # evaluate the newly constructed node
    value(root.right)
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")

  ms = Monkeys.new(text.lines)
  puts ms.value("root")

  ms2 = Monkeys.new(text.lines)
  ms2.monkeys["root"].op = "=="
  ms2.monkeys["humn"].value = :goal
  ms2.value("root")
  pp ms2.monkeys

  ms2.solve("root")
  puts ms2.value("humn")

  # idea: plug the obtained value in the original eval tree. will that help?
end
