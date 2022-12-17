#!/usr/bin/env ruby

Valve = Struct.new(:name, :rate, :tunnels) do
  PATTERN = /Valve (\S+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
  def self.parse(line)
    line =~ PATTERN or raise line
    name = $1
    rate = $2.to_i # forgot it AGAIN
    tunnels = $3.split(", ")
    new(name, rate, tunnels)
  end
end

class Graph
  # @return [Hash{String => Valve}]
  attr_reader :valves
  def initialize(valves)
    @valves = {}
    valves.each { |v| @valves[v.name] = v }
  end

  def to_dot
    dot = "graph g {\n"
    valves.each do |_k, v|
      dot << "  #{v.name}[label=\"#{v.name} #{v.rate}\"];\n"
      v.tunnels.each do |t|
        dot << "    #{v.name} -- #{t};\n" if v.name <= t
      end
    end
    dot << "}\n"
    dot
  end
end

if $PROGRAM_NAME == __FILE__
  arg = ARGV[0] || "input.txt"
  text = File.read(arg)

  # PLAN so far:
  # Walk around the graph, visiting valued nodes.
  # Each node's VALUE is the pressure it will release since now
  # until the timer expires (REMEMBER to account for the opening time).

  # Maybe we can produce all permutations of nodes and then pick the most
  # valued Hamiltonian path, (REMEMBERING to cut it off at the time limit)
  
  valves = text.lines.map {|line| Valve.parse(line) }
  puts "#{valves.size} valves"

  # PLAN so far:
  # Oh shoot, 63 nodes give way too many permutations :-(
  
  good = valves.find_all { |v| v.rate > 0 }
  puts "#{good.size} valves that work"

  # PLAN so far: Yay, MUCH better, only 15 working valves, (15!) permutations
  # will surely work... Oh [censored] 1307674368000 (1.3 tera) is still too many

  g = Graph.new(valves)
  File.write(arg + ".dot", g.to_dot)
end
