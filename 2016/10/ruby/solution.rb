#!/usr/bin/env ruby

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

# Not necessary for the solution, but interesting to see.
# In graphviz format: http://graphviz.org/content/dot-language
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
    @instrs.each do |type, args|
      next unless type == :bot

      bnum = args[:bot]
      low  = build_obj(args[:low_type],  args[:low_num])
      high = build_obj(args[:high_type], args[:high_num])

      @bots[bnum].connect(low, high)
    end
  end

  def pass_inputs
    @instrs.each do |type, args|
      next unless type == :value
      @bots[args[:bot]].input(args[:value])
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

File.write("input.dot", instrs_as_graph(instructions))

puts "Part A:"
f = Factory.new(instructions)
f.build_bots
Bot.watch_for(61, 17)
f.pass_inputs

puts "Part B:"
f.partb
