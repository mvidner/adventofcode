#!/usr/bin/env ruby
require "pp"

# @param line [String]
# @return [Array(Symbol, Hash)] a pair: instr type, instr arguments
#   where type is one of :value, :bot
def parse_instr(line)
  case line
  when /^value (\d+) goes to bot (\d+)/
    args = {value: $1.to_i, bot: $2.to_i}
    [:value, args]
  when /^bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/
    args = {
      bot: $1.to_i,
      low_type: $2.to_sym, low_num: $3.to_i,
      high_type: $4.to_sym, high_num: $5.to_i
    }
    [:bot, args]
  else
    raise "Unmatched instr #{line}"
  end
end

def instrs_as_graph(instrs)
  dot = ""
  dot << "digraph instructions {\n"
  instrs.each do |type, args|
    case type
    when :value
      dot << "\"#{args[:value]}\""
      dot << " -> \"bot #{args[:bot]}\";\n"
    when :bot
      bot = args[:bot]
      # funny oom bug
      # dot <<
      dot << "\"bot #{bot}\" [shape=record,label=\"<l>L|bot #{bot}|<h>H\"];\n"
      dot << "\"bot #{args[:bot]}\":l"
      dot << " -> \"#{args[:low_type] } #{args[:low_num] }\";\n"
      dot << "\"bot #{args[:bot]}\":h"
      dot << " -> \"#{args[:high_type]} #{args[:high_num]}\";\n"
    else
      raise
    end
  end
  dot << "}\n"
  dot
end

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
    @instrs = instrs
    @bots    = Hash.new { |h, k| h[k] = Bot.new(k) }
    @outputs = Hash.new { |h, k| h[k] = Output.new(k) }
    @value_instrs = []
  end

  def build_bots
    @instrs.each do |type, args|
      next unless type == :bot

      bnum = args[:bot]
      low  = obj(args[:low_type],  args[:low_num])
      high = obj(args[:high_type], args[:high_num])
      @bots[bnum].give(low, high)
    end
  end

  def pass_inputs
    @instrs.each do |type, args|
      next unless type == :value
      @bots[args[:bot]].input(args[:value])
    end
  end

  def obj(type, num)
    case type
    when :bot
      @bots[num]
#      [:@bots, num]
    when :output
      @outputs[num]
#      [:@outputs, num]
    else
      raise
    end
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

instructions = File.readlines("input.txt").map { |line| parse_instr(line) }

File.write("input.dot", instrs_as_graph(instructions))

puts "Part A:"
f = Factory.new(instructions)
f.build_bots
f.pass_inputs
f.find(61, 17)

puts "Part B:"
f.partb
