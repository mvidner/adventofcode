#!/usr/bin/env ruby

ValueInstr = Struct.new(:value, :bot)
BotInstr   = Struct.new(:bot, :low_type, :low_num, :high_type, :high_num)

# @param line [String]
# @return [ValueInstr|BotInstr]
def parse_instr(line)
  case line
  when /^value (\d+) goes to bot (\d+)/
    ValueInstr.new($1.to_i, $2.to_i)
  when /^bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/
    BotInstr.new($1.to_i,
                 $2.to_sym, $3.to_i,
                 $4.to_sym, $5.to_i)
  else
    raise "Unmatched instr #{line}"
  end
end

# Not necessary for the solution, but interesting to see.
# In graphviz format: http://graphviz.org/content/dot-language
def instrs_as_graph(instrs)
  dot = ""
  dot << "digraph instructions {\n"
  instrs.each do |i|
    case i
    when ValueInstr
      dot << "\"#{i.value}\""
      dot << " -> \"bot #{i.bot}\";\n"
    when BotInstr
      # funny oom bug
      # dot <<
      dot << "\"bot #{i.bot}\" [shape=record,label=\"<l>L|bot #{i.bot}|<h>H\"];\n"
      dot << "\"bot #{i.bot}\":l"
      dot << " -> \"#{i.low_type } #{i.low_num}\";\n"
      dot << "\"bot #{i.bot}\":h"
      dot << " -> \"#{i.high_type} #{i.high_num}\";\n"
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

File.write("input.dot", instrs_as_graph(instructions))

puts "Part A:"
f = Factory.new(instructions)
f.build_bots
Bot.watch_for(61, 17)
f.pass_inputs

puts "Part B:"
f.partb
