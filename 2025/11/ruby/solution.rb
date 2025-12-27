#!/usr/bin/env ruby
require "set"

class Graph
  def self.from_file(filename)
    text = File.read(filename)
    adjacent = {}
    text.lines.each do |line|
      from, to = line.split(": ")
      destinations = to.split
      adjacent[from] = destinations
    end

    new(adjacent)
  end

  # @param vtx [Vertex]
  # @return [Enumerable<Vertex>] from a vertex to its adjacent vertices
  def adjacent(vtx)
    @adjacent[vtx] || []
  end

  def initialize(adjacent)
    @adjacent = adjacent
  end

  def dump_graphviz
    puts "digraph g {"
    puts "  you[color=red];"
    adjacent.each do |v, ws|
      ws.each do |w|
        puts "  #{v} -> #{w};"
      end
    end
    puts "}"
  end

  def stats
    {
      num_vs: @adjacent.keys.size,
      num_es: @adjacent.values.map(&:size).sum
    }
  end

  # @return [Graph] one with the edges reversed
  def reverse
    rev_adjacent = {}
    @adjacent.each do |v, ws|
      ws.each do |w|
        # w -> v
        rev_adjacent[w] ||= Set.new
        rev_adjacent[w] << v
      end
    end
    self.class.new(rev_adjacent)
  end

  # A push+take Queue (where take == shift)
  class Queue < Array
    def take
      shift
    end
  end

  # A push+take Stack (where take == pop)
  class Stack < Array
    def take
      pop
    end
  end

  # @param explored [Set] #add, #include?
  def depth_first_search(root, goal_p, explored = [].to_set)
    iterated_search(root, goal_p, explored, Stack.new)
  end

  # @param explored [Set] #add, #include?
  def breadth_first_search(root, goal_p, explored = [].to_set)
    iterated_search(root, goal_p, explored, Queue.new)
  end

  # implementing the Pseudocode from
  # https://en.wikipedia.org/wiki/Breadth-first_search and
  # https://en.wikipedia.org/wiki/Depth-first_search
  # @param self [Graph] graph implementing adjacent(Vertex) -> Enumerable[Vertex]
  # @param root [Vertex]
  # @param goal_p Proc(Vertex -> Boolean)
  # @param explored [#add, #include?] a Set of explored vertices to skip the next time
  # @param todo [#push,#take,#empty?] a Queue or a Stack
  # @return [Vertex or nil] goal vertex
  def iterated_search(root, goal_p, explored, todo)
    explored.add(root)
    todo.push(root)
    until todo.empty?
      v = todo.take
      return v if goal_p.call(v)

      adjacent(v).each do |w|
        next if explored.include?(w)

        explored.add(w)
        todo.push(w)
      end
    end
    # not found
  end

  # @param keep_set [#include?]
  # @return [Graph] new graph
  def prune_by_vertices(keep_set)
    pruned_adjacent = {}
    @adjacent.each do |v, ws|
      next unless keep_set.include?(v)

      pruned_adjacent[v] = ws.find_all { |w| keep_set.include?(w) }
    end
    self.class.new(pruned_adjacent)
  end

  def reachable_vertices(start_v)
    # reachable vertices are the explored ones
    explored = Set.new
    goal_p = ->(_v) { false }
    breadth_first_search(start_v, goal_p, explored)
    explored
  end

  # return a new pruned graph, excluding the vertices
  # that don't lie on a path from start_v to goal_v
  def pruned_graph(start_v, goal_v)
    reachable = reachable_vertices(start_v)

    reverse_graph = reverse
    possible_starting = reverse_graph.reachable_vertices(goal_v)

    result = prune_by_vertices(reachable.intersection(possible_starting))
    result
  end

  # A dummy `explored` Set to enable counting paths
  class ForeverExplorer
    def add(_vtx); end

    def include?(_vtx)
      false
    end
  end

  # can afford a recursive alogithm without cycle checking,
  # because the input happens to be good
  def count_paths(start_v, goal_v)
    pruned = pruned_graph(start_v, goal_v)
    # puts "Input:  #{stats.inspect}"
    # puts "Pruned: #{pruned.stats.inspect}"

    n = 0
    i = 0
    # count all ways of reaching the goal
    goal_p = lambda do |v|
      n += 1 if v == goal_v
      i += 1
      print "." if 0 == i % 1_000_000
      false
    end
    explored = ForeverExplorer.new
    pruned.depth_first_search(start_v, goal_p, explored)
    n
  end

  def report_count_paths(start_v, goal_v)
    n = count_paths(start_v, goal_v)
    puts "Paths #{start_v} -> #{goal_v}: #{n}"
    n
  end
end

if $PROGRAM_NAME == __FILE__
  g = Graph.from_file(ARGV[0] || "input.txt")
  # g.dump_graphviz
  g.report_count_paths("you", "out")

  fd = g.report_count_paths("fft", "dac")
  df = g.report_count_paths("dac", "fft")
  if fd > 0
    a = g.report_count_paths("svr", "fft")
    m = fd
    z = g.report_count_paths("dac", "out")
  else
    a = g.report_count_paths("svr", "dac")
    m = df
    z = g.report_count_paths("fft", "out")
  end
  puts "Total dac/fft paths: #{a * m * z}"
end
