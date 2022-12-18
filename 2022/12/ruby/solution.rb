#!/usr/bin/env ruby
require "set"

Pos = Struct.new(:r, :c) do
  def +(pair)
    Pos.new(r + pair[0], c + pair[1])
  end
end

class Hill
  def initialize(text)
    @rows = text.lines.map(&:chomp)
    @w = @rows.first.size
    @h = @rows.size

    @start = find("S")
    @rows[@start.r][@start.c] = "a"

    @end = find("E")
    @rows[@end.r][@end.c] = "z"
  end

  def find(letter)
    row = @rows.index { |r| r.include?(letter) }
    col = @rows[row].index(letter)
    Pos.new(row, col)
  end

  def at(pos)
    # puts "at #{pos}"
    letter = @rows[pos.r][pos.c]
    letter.ord - 'a'.ord
  end

  def dump
    puts "start #{@start.inspect}"
    puts "end   #{@end.inspect}"
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

  DELTAS = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1]
  ]

  # @return [Enumerable<Pos>]
  def reachable_from(pos, reverse: false)
    reach = DELTAS.map { |d| pos + d }
    reach = reach.find_all { |p| (0...@h).include?(p.r) && (0...@w).include?(p.c) }
    reach = reach.find_all do |p|
      if reverse
        valid_step_up(p, pos)
      else
        valid_step_up(pos, p)
      end
    end
    reach
  end

  def valid_step_up(from, to)
    at(to) <= at(from) + 1
  end

  def steps_to_summit(reverse: false)
    steps = 0
    start, end_ = @start, @end
    start, end_ = end_, start if reverse

    olds = [].to_set
    currents = [start].to_set

    loop do
      steps += 1
      puts "WAVE olds: #{olds}" if ENV["WAVE"]
      puts "WAVE curs: #{currents}" if ENV["WAVE"]

      news = wave(olds, currents) do |cur|
        reachable_from(cur, reverse: reverse)
      end
      if ENV["WAVE"]
        puts "WAVE news:"
        pp news
      end

      if reverse
        return steps if news.any? { |n| at(n) == 0 }
      else
        return steps if news.include?(end_)
      end
      break if news.empty?

      olds = olds | currents
      currents = news
    end
  end

end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")

  hill = Hill.new(text)
  hill.dump
  puts hill.steps_to_summit
  puts hill.steps_to_summit(reverse: true)
end
