#!/usr/bin/env ruby
require "set"

class Pos < Array
  def +(other)
    Pos[r + other.r, c + other.c]
  end

  def %(moduli)
    Pos[r % moduli.r, c % moduli.c]
  end

  def r
    self[0]
  end

  def c
    self[1]
  end
end

Blizzard = Struct.new(:pos, :dir)

class BlizzardBasin
  def initialize(text)
    @blizzards = []

    rows = text.lines.map(&:chomp)
    # text includes the surrounding basin walls. remove them
    rows[1 .. -2].each_with_index do |r, ri|
      # omit the left and right walls
      r[1 .. -2].chars.each_with_index do |c, ci|
        pos = Pos[ri, ci]
        case c
        when "<"
          @blizzards << Blizzard.new(pos, Pos[0, -1])
        when ">"
          @blizzards << Blizzard.new(pos, Pos[0, 1])
        when "^"
          @blizzards << Blizzard.new(pos, Pos[-1, 0])
        when "v"
          @blizzards << Blizzard.new(pos, Pos[1, 0])
        when "."
          # nothing
        else
          raise "UFO #{c.inspect} at (#{pos})"
        end
      end
    end

    @blizzard_positions = nil

    @w = rows.first.size - 2
    @h = rows.size - 2
    puts "W H #{@w} #{@h}"
    @start = Pos[-1, 0]
    @end = Pos[@h, @w - 1]
  end

  def move_blizzards
    # mutate in place
    @blizzards.each do |b|
      b.pos = (b.pos + b.dir) % Pos[@h, @w]
    end

    # invalidate
    @blizzard_positions = nil
  end

  # cache
  # @return [Set<Pos>]
  def blizzard_positions
    return @blizzard_positions if @blizzard_positions

    @blizzard_positions = @blizzards.map(&:pos).to_set
  end


  # currents and news are sets
  # go takes one current and returns the ones reachable from it
  # return news
  def edge_wave(currents, &go)
    news = Set.new
    currents.each do |cur|
      candidates = go.call(cur)
      candidates.each do |can|
        news << can # unless  currents.include?(can)
      end
    end
    news
  end

  DELTAS = [
    Pos[-1, 0],
    Pos[1, 0],
    Pos[0, -1],
    Pos[0, 1],
    # can stand still
    Pos[0, 0]
  ]

  # @return [Enumerable<Pos>]
  def edge_reachable_from(pos, reverse: false)
    reach = DELTAS.map { |d| pos + d }

    reach = reach.find_all do |p|
      next true if p == @end || p == @start
      (0...@h).include?(p.r) && (0...@w).include?(p.c)
    end

    reach = reach.find_all do |p|
      ! blizzard_positions.include?(p)
    end

    reach
  end

  def valid_step_up(from, to)
    at(to) <= at(from) + 1
  end

  def steps_to_end(reverse: false)
    @steps = 0
    start, end_ = @start, @end
    start, end_ = end_, start if reverse

    currents = [start].to_set

    loop do
      @steps += 1
      move_blizzards

      puts "WAVE curs: #{currents}" if ENV["WAVE"]

      news = edge_wave(currents) do |cur|
        edge_reachable_from(cur, reverse: reverse)
      end
      if ENV["WAVE"]
        puts "WAVE news:"
        pp news
      end

      if reverse
        return @steps if news.any? { |n| at(n) == 0 }
      else
        return @steps if news.include?(end_)
      end
      break if news.empty?

      currents = news
    end
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  bb = BlizzardBasin.new(text)

  puts bb.steps_to_end.inspect
end
