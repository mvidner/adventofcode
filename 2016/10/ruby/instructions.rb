# shared definitions for solution.rb and graph.rb

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

