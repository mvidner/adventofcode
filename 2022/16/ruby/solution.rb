#!/usr/bin/env ruby

Valve = Struct.new(:rate, :tunnels) do
  PATTERN = /Valve (\S+) has flow rate=(\d+); tunnels? leads? to valves? (\S+)/
  def self.parse(line)
    line =~ PATTERN or raise line
    name = $1
    rate = $2.to_i # forgot it AGAIN
    tunnels = $3.split(",")
    new(rate, tunnels)
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")

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
end
