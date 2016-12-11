#!/usr/bin/env ruby
require "fileutils"

require_relative "instructions"

# Not necessary for the solution, but interesting to see.
# In graphviz format: http://graphviz.org/content/dot-language
def instrs_as_graph(instrs)
  dot = ""
  dot << "digraph instructions {\n"
  dot << "rankdir=LR;\n"
  instrs.each do |i|
    case i
    when ValueInstr
      dot << "\"#{i.value}\""
      dot << " -> \"bot #{i.bot}\";\n"
    when BotInstr
      # funny oom bug
      # dot <<
      dot << "\"bot #{i.bot}\" [shape=record,label=\"<h>H|bot #{i.bot}|<l>L\"];\n"
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

instructions = File.readlines("input.txt").map { |line| parse_instr(line) }

def dot(basename)
  system "dot -s10 -Tgif -o #{basename}.gif #{basename}.dot"
end

def all_partial_graphs(instructions)
  FileUtils.mkdir_p "graph"
  partial_instructions = []
  instructions.each_with_index do |instr, j|
    partial_instructions << instr
    File.write("graph/input#{j}.dot", instrs_as_graph(partial_instructions))
    dot "graph/input#{j}"
  end
end

def complete_graph(instructions)
  File.write("input.dot", instrs_as_graph(instructions))
  dot "input"
end

complete_graph(instructions)
all_partial_graphs(instructions)
