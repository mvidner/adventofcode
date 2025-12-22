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

  # @return [Hash{String => Array<String>}]}] from a vertex to its adjacent vertices
  attr_reader :adjacent

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

  # can afford a recursive alogithm without cycle checking,
  # because the input happens to be good
  def count_paths(start_v, goal_v)
    return 1 if start_v == goal_v

    next_vs = adjacent[start_v]
    return 0 if next_vs.nil?

    next_vs.map { |next_v| count_paths(next_v, goal_v) }.sum
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
