#!/usr/bin/env ruby

require_relative "instructions"

class Bot
  def initialize(id)
    @id = id
    @values = []
  end

  def self.watch_for(a, b)
    @@watch_for = [a, b].sort
  end

  def input(vnum)
    @values << vnum

    if @values.size == 2
      low, high = @values.sort
      if [low, high] == @@watch_for
        puts "Bot #{@id} found #{@@watch_for}"
      end
      @low.input(low)
      @high.input(high)
    end
  end

  def connect(low, high)
    raise if @low || @high
    @low = low
    @high = high
  end

  def inspect
    "(B#{@id} #{@values}->#{[@low.class,@high.class]})"
  end
end

Output = Struct.new(:id, :value) do
  def input(vnum)
    self.value = vnum
    # puts "OUT #{id} got #{value}"
  end

  def inspect
    "#O<##{id}=#{value}>"
  end
end

class Factory
  def initialize(instrs)
    @instrs = instrs
    @bots    = Hash.new { |h, k| h[k] = Bot.new(k) }
    @outputs = Hash.new { |h, k| h[k] = Output.new(k) }
  end

  def build_bots
    @instrs.each do |i|
      next unless i.is_a? BotInstr

      low  = build_obj(i.low_type,  i.low_num)
      high = build_obj(i.high_type, i.high_num)

      @bots[i.bot].connect(low, high)
    end
  end

  def pass_inputs
    @instrs.each do |i|
      next unless i.is_a? ValueInstr
      @bots[i.bot].input(i.value)
    end
  end

  def build_obj(type, num)
    case type
    when :bot
      @bots[num]
    when :output
      @outputs[num]
    else
      raise
    end
  end

  def partb
    outputs = [@outputs[0].value, @outputs[1].value, @outputs[2].value]
    puts "The product of #{outputs} is #{outputs.reduce(1, :*)}"
  end
end

instructions = File.readlines("input.txt").map { |line| parse_instr(line) }

puts "Part A:"
f = Factory.new(instructions)
f.build_bots
Bot.watch_for(61, 17)
f.pass_inputs

puts "Part B:"
f.partb
