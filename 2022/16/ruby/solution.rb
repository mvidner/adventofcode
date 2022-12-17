#!/usr/bin/env ruby

# name [String]
# rate [Integer]
# tunnels [Array<Array(String,Integer)>] pairs destination, distance
Valve = Struct.new(:name, :rate, :tunnels) do
  PATTERN = /Valve (\S+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
  def self.parse(line)
    line =~ PATTERN or raise line
    name = $1
    rate = $2.to_i # forgot it AGAIN
    tunnels = $3.split(", ").map { |dest| [dest, 1] }
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

  def prune_zero_vertices
    # first disconnect the zeros...
    valves.each do |k, v|
      next if v.rate > 0

      p v
      case v.tunnels.size
      when 1
        # leaf zero
        v2 = valves[v.tunnels[0].first]
        v2.tunnels.reject! { |d, _len| d == k }

        v.tunnels = []
      when 2
        puts "pair"
        v2 = valves[v.tunnels[0].first]
        v3 = valves[v.tunnels[1].first]

        p v2
        p v3
        # t2 is a pair, mutate it in place
        t2 = v2.tunnels.find { |t| t.first == k }
        t3 = v3.tunnels.find { |t| t.first == k }
        p t2
        p t3
        new_len = t2.last + t3.last

        t2[0] = v3.name
        t2[1] = new_len
        t3[0] = v2.name
        t3[1] = new_len

        v.tunnels = []
      end
    end

    # ... then do a second pass of eliminating them
    valves.reject! do |_k, v|
      v.tunnels.empty?
    end
  end

  def to_dot
    dot = "graph g {\n"
    valves.each do |_k, v|
      dot << "  #{v.name}[label=\"#{v.name} #{v.rate}\"];\n"
      v.tunnels.each do |v2, dist|
        dot << "    #{v.name} -- #{v2} [label=\"#{dist}\"];\n" if v.name <= v2
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
  g.prune_zero_vertices
  File.write(arg + ".dot", g.to_dot)
end
