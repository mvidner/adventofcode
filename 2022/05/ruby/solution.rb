#!/usr/bin/ruby

class Crane
  def initialize(stacks)
    # from-to must translate 0-1
    # Top of stack = element 0
    @stacks = stacks.map { |string| string.split(//) }
  end

  def run(program)
    program.lines.each do |line|
      next unless line =~ /move (.*) from (.*) to (.*)/

      move($1.to_i, $2.to_i, $3.to_i)
    end
  end

  def move(count, from, to)
    #count.times { move1(from, to) }
    @stacks[to-1].unshift(* @stacks[from - 1].shift(count))
  end

  def move1(from, to)
    @stacks[to-1].unshift(@stacks[from - 1].shift)
  end
  
  def tops
    @stacks.map { |s| s[0] }.join
  end
end

#text = File.read(ARGV[0] || "input.txt")
#data = text.lines.map(&:chomp)

sample = Crane.new(
  ["NZ", "DCM", "P"]
)
inst = <<TXT
move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
TXT
sample.run(inst)
puts sample.tops

ok = Crane.new(
["GPNR",
"HVSCLBJT",
"LNMBDT",
"BSPVR",
"HVMWSQCG",
"JBDCSQW",
"LQF",
"VFLDTHMW",
"FJMVBPL"]
)
inst = File.read(ARGV[0] || "input.txt")
ok.run(inst)
puts ok.tops
