#!/usr/bin/env ruby
require "set"

Tunnel = Struct.new(:dest, :len) do
  def inspect
    "(#{len})->#{dest}"
  end
end

# name [String]
# rate [Integer]
# tunnels [Array<Tunnel>]
Valve = Struct.new(:name, :rate, :tunnels) do
  PATTERN = /Valve (\S+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
  def self.parse(line)
    line =~ PATTERN or raise line
    name = $1
    rate = $2.to_i # forgot it AGAIN
    tunnels = $3.split(", ").map { |dest| Tunnel[dest, 1] }
    v = new(name, rate, tunnels)
    # puts v
    # p v
    # pp v
    v
  end

  def inspect
    "#i<V #{name} #{rate} #{tunnels}>"
  end

  def to_s
    "#s<V #{name} #{rate} #{tunnels}>"
  end
end

class Graph
  # @return [Hash{String => Valve}]
  attr_reader :valves
  def initialize(valves)
    @valves = {}
    valves.each { |v| @valves[v.name] = v }
  end

  def subgraph(names)
    names = names.to_set
    new_valves_a = names.map do |n|
      v = valves[n]
      new_tunnels = v.tunnels.find_all { |t| names.include?(t.dest) }
      Valve.new(v.name, v.rate, new_tunnels)
    end
    Graph.new(new_valves_a)
  end

  def prune_zero_vertices
    # first disconnect the zeros...
    valves.each do |k, v|
      next if v.rate > 0

      case v.tunnels.size
      when 1
        # leaf zero
        v2 = valves[v.tunnels[0].dest]
        v2.tunnels.reject! { |d, _len| d == k }

        v.tunnels = []
      when 2
        v2 = valves[v.tunnels[0].dest]
        v3 = valves[v.tunnels[1].dest]

        # t2 is a pair, mutate it in place
        t2 = v2.tunnels.find { |t| t.dest == k }
        t3 = v3.tunnels.find { |t| t.dest == k }
        new_len = t2.len + t3.len

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
      v.tunnels.each do |t|
        v2, dist = t.dest, t.len
        dot << "    #{v.name} -- #{v2} [label=\"#{dist}\"];\n" if v.name <= v2
      end
    end
    dot << "}\n"
    dot
  end

  # @param start_name [String] name of valve where I am now
  # @return [Hash{String => Integer}] valve name -> value:
  #   how much it will contribute if I go to it and open it
  #   (before the time limit expires)
  # DUH, should also ignore valves that are already open?!
  def appraise_vertices(start_name, time_remaining)
    puts "APPRAISE #{start_name}, #{time_remaining}"

    add_tunnels_from(start_name)

    values = {}

    v = valves[start_name]
    v.tunnels.each do |t|
      dest, len = t.dest, t.len
      time_left = time_remaining - len - 1 # get there + 1 open it
      time_left = 0 if time_left < 0

      dest_v = valves[dest]
      value = dest_v.rate * time_left
      puts "#{dest_v.rate} * #{time_left} = #{value}"
      # TODO: value = 0 if dest_v.is_open
      values[dest] = value
    end
    p values
    values
  end

  def complete
    valves.each do |k, _v|
      puts "From #{k}"
      add_tunnels_from(k)
    end
  end

  def add_tunnels_from(start_name)
    # nothing to do here?
    return if valves[start_name].tunnels.size == valves.size - 1

    # from start_name
    # String name -> Integer length
    # does not contain self (start_name)
    direct_lengths = { start_name => 0 } # TODO remove before assigning back

    olds = [].to_set
    currents = [start_name].to_set

    loop do
      news = wave(olds, currents) do |cur|
        valves[cur].tunnels.map do |t|
          v2 = valves[t.dest]

          new_len = direct_lengths[cur] + t.len
          if !direct_lengths[t.dest] || direct_lengths[t.dest] > new_len
            direct_lengths[t.dest] = new_len
          end

          t.dest
        end
      end
      # print "New: "
      # p news
      # print "Direct: "
      # p direct_lengths

      break if direct_lengths.size == valves.size

      olds = olds | currents
      currents = news
    end
    p direct_lengths
    direct_lengths.delete(start_name)
    valves[start_name].tunnels = direct_lengths.map { |dest, len| Tunnel[dest, len] }
  end

  # olds currents and news are sets
  # go takes one current and returns the ones reachable from it
  # return news
  def wave(olds, currents, &go)
    news = Set.new
    currents.each do |cur|
      candidates = go.call(cur)
      candidates.each do |can|
        news << can unless olds.include?(can) || currents.include?(can)
      end
    end
    news
  end

end

if $PROGRAM_NAME == __FILE__
  arg = ARGV[0] || "input.txt"
  text = File.read(arg)

  valves = text.lines.map {|line| Valve.parse(line) }
  puts "#{valves.size} valves"

  g = Graph.new(valves)
  g.prune_zero_vertices
  # File.write(arg + ".dot", g.to_dot)

  # g.appraise_vertices("AA", 30)
  g.complete

  g2 = g.subgraph(["AA", "DD", "JJ"])
  p g2
end
