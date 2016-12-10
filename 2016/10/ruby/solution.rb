#!/usr/bin/env ruby
require "pp"

instructions = File.readlines("input.txt")

class Bot
  def initialize(id)
    @id = id
    @values = []
  end

  def input(vnum)
    @values << vnum

    if @values.size == 2
      puts "YAY B #{@id}"
#      puts inspect
      low  = @values.min
      high = @values.max
      if [low, high] == [17, 61]
        puts "BINGO B #{@id}"
      end
      @low.input(low)
      @high.input(high)
    end
  end

  def give(low, high)
    raise if @low || @high
    @low = low
    @high = high
  end

  def inspect
    "(B#{@id} #{@values}->#{[@low,@high]})"
  end
end

class Output
  def initialize(id)
    @id = id
  end

  def input(vnum)
    @value = vnum
    puts "OUT #{@id} got #{@value}"
  end

  def value
    @value
  end
end

class Factory
  def initialize(instrs)
    @bots    = Hash.new { |h, k| h[k] = Bot.new(k) }
    @outputs = Hash.new { |h, k| h[k] = Output.new(k) }
    @value_instrs = []
    parse(instrs)
  end

  def parse(instrs)
    instrs.each do |instr|
      case instr
      when /^value (\d+) goes to bot (\d+)/
        instr_value($1.to_i, $2.to_i)
      when /^bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/
        instr_give($1.to_i, $2, $3.to_i, $4, $5.to_i)
      else
        raise "Unmatched instr #{instr}"
      end
    end
  end

  def instr_value(vnum, bnum)
    @value_instrs << {vnum: vnum, bnum: bnum}
  end

  def instr_give(bnum, ltype, lnum, htype, hnum)
    low = obj(ltype, lnum)
    high = obj(htype, hnum)
    @bots[bnum].give(low, high)
  end

  def obj(type, num)
    case type
    when "bot"
      @bots[num]
#      [:@bots, num]
    when "output"
      @outputs[num]
#      [:@outputs, num]
    else
      raise
    end
  end

  def self.real_obj(sym, num)
    instance_variable_get(sym)[num]
    # argh
  end

  def run_values
    @value_instrs.each do |vi|
      @bots[vi[:bnum]].input(vi[:vnum])
    end

    self
  end

  def find(* args)
    puts "finding #{args}"
    p @outputs
#    pp @bots
    self
  end

  def partb
    puts [@outputs[0].value, @outputs[1].value, @outputs[2].value]
    puts @outputs[0].value * @outputs[1].value * @outputs[2].value
  end
end

puts "Part A:"
f = Factory.new(instructions).run_values.find(61, 17)
puts "Part B:"
f.partb
