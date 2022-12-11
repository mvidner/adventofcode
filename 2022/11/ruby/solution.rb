#!/usr/bin/env ruby

class Monkey
  def self.parse(text)
    text =~ /Starting items: (.*)/
    items = $1.split(", ").map(&:to_i)

    text =~ /Operation: (.*)/
    operation = $1

    text =~ /Test: divisible by (.*)/
    divisible = $1.to_i

    text =~ /If true: throw to monkey (.*)/
    if_true = $1.to_i

    text =~ /If false: throw to monkey (.*)/
    if_false = $1.to_i

    new(items, operation, divisible, if_true, if_false)
  end

  attr_accessor :items, :operation, :divisible, :if_true, :if_false

  attr_reader :inspection_count

  def initialize(items, operation, divisible, if_true, if_false)
    @items = items
    @operation = operation
    @divisible = divisible
    @if_true = if_true
    @if_false = if_false

    @inspection_count = 0
  end

  # Inspect an item, don't throw it yet
  # @return [Integer,nil] target monkey to throw the current item to,
  #   or nil if no items left
  def inspect_one
    return nil if @items.empty?

    @inspection_count += 1

    worry
    bore
    if items[0] % divisible == 0
      if_true
    else
      if_false
    end
  end

  def old
    items[0]
  end

  def new=(value)
    items[0] = value
  end

  def worry
    instance_eval(operation)
  end

  def bore
    items[0] /= 3
  end

  def throw
    items.shift
  end

  def catch(item)
    items.push(item)
  end
end

class MonkeyBusiness
  attr_reader :monkeys

  def initialize(monkeys)
    @monkeys = monkeys
  end

  def run(rounds:)
    rounds.times { run_one }
  end

  def run_one
    monkeys.each do |m|
      loop do
        target = m.inspect_one
        break if target.nil?

        monkeys[target].catch(m.throw)
      end
    end
  end

  def level
    sorted = monkeys.sort { |a, b| a.inspection_count <=> b.inspection_count }
    sorted[-2].inspection_count * sorted[-1].inspection_count
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  monkey_texts = text.split("\n\n")
  monkeys = monkey_texts.map do |txt|
    Monkey.parse(txt)
  end

  biz = MonkeyBusiness.new(monkeys)

  biz.run(rounds: 20)
  puts biz.level
end
