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
      # puts "From #{k}"
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
    # p direct_lengths
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

  # @return [Array(Numeric,Array<String>)] value, valve_order
  def solve(start_n:, minutes:)
    # solve_with_permutations(start_n: start_n, minutes: minutes)
    solve_dfs(
      minutes: minutes,
      already_committed: 0,
      already_open_a: [start_n],
      todo: valves.keys.to_a - [start_n]
    )
  end

  MIL = 1_000_000

  # needs a complete graph
  # @return [Array(Numeric,Array<String>)] value, valve_order
  def solve_with_permutations(start_n:, minutes:)
    raise ArgumentError, "#{start_n.inspect} not among vertex names" unless valves.key?(start_n)

    v_names = valves.keys.to_a - [start_n]

    max = -1
    max_path = nil
    perms = v_names.permutation
    todo = perms.size
    perms.each_with_index do |v_order, i|
      $sus = i % MIL == 0
      puts "i #{i/MIL.to_f}M of #{todo/MIL.to_f}M" if $sus

      result = walk([start_n] + v_order, minutes: minutes)
      puts "#{result} <- #{v_order}\n\n" if $sus
      if result >= max
        max = result
        max_path = [start_n] + v_order
      end
    end
    [max, max_path]
  end

  # @param already_open_a [Array<String>] names of already open valves, in order, and we are standing at the last of them
  # @param already_committed [Numeric] how much *already_open_a* will comtribute to the solution
  # @param minutes [Numeric] minutes left
  # @param todo names of valves left to do
  #
  # How do we reduce run time? if <=0 minutes are left, skip exploring *todo*
  #
  # @return [Array(Numeric,Array<String>)] value, valve_order
  def solve_dfs(minutes:, already_committed:, already_open_a:, todo:)
    puts "DFS: #{minutes}, #{already_committed}, #{already_open_a}, #{todo}"

    return [already_committed, already_open_a] if minutes <= 0
    return [already_committed, already_open_a] if todo.empty?

    this_n = already_open_a.last
    v = valves[this_n]

    # unspecified order, no heuristic
    results = todo.map do |next_n|
      # go there...
      # SLOW
      t = v.tunnels.find { |t| t.dest == next_n }
      minutes_left = minutes - t.len
      next [already_committed, already_open_a] if minutes_left <= 0

      # ... open it ...
      nextv = valves[next_n]
      minutes_left -= 1
      next [already_committed, already_open_a] if minutes_left <= 0

      contribution = minutes_left * nextv.rate

      # ... recurse
      value, order = solve_dfs(minutes: minutes_left,
                               already_committed: already_committed + contribution,
                               already_open_a: already_open_a + [next_n],
                               todo: todo - [next_n]
                              )

      [value, order]
    end

    result = results.max_by { |e| e.first }

  end

  def walk(v_order, minutes:)
    total = 0
    minutes_left = minutes

    (v_order + [nil]).each_cons(2) do |this_n, next_n|
      v = valves[this_n]
      # open *v* (unless its rate is 0; we start at such AA)
      if v.rate == 0
        puts "#{this_n}: skipping, rate 0" if $sus
      else
        minutes_left -= 1
        if minutes_left <= 0
          puts "timeout at opening #{this_n}" if $sus
          return total
        end
        contribution = minutes_left * v.rate
        puts "#{this_n}: #{contribution} = #{minutes_left} * #{v.rate}" if $sus
        total += contribution
      end

      break if next_n.nil?

      t = v.tunnels.find { |t| t.dest == next_n }
      minutes_left -= t.len
      if minutes_left <= 0
        puts "timeout at travel to #{next_n}" if $sus
        return total
      end
    end

    total
  end
end

if $PROGRAM_NAME == __FILE__
  arg = ARGV[0] || "input.txt"
  text = File.read(arg)

  valves = text.lines.map {|line| Valve.parse(line) }
  # puts "#{valves.size} valves"

  g = Graph.new(valves)
  g.prune_zero_vertices
  puts "#{g.valves.size} valves after pruning"
  # File.write(arg + ".dot", g.to_dot)

  # g.appraise_vertices("AA", 30)
  g.complete

  # g2 = g.subgraph(["AA", "DD", "JJ"])
  # result = g2.solve(start_n: "AA", minutes: 7)
  # g = g.subgraph(g.valves.keys.take(12))
  result = g.solve(start_n: "AA", minutes: 30)
  puts "Best result: #{result.inspect}"
end
