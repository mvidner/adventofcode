#!/usr/bin/env ruby
require "set"

Cube = Struct.new(:x, :y, :z) do
  def neighbor(delta)
    Cube.new(x + delta[0], y + delta[1], z + delta[2])
  end
end

class Droplet
  attr_reader :cubes
  def initialize(cubes)
    @cubes = cubes.to_set
  end

  NEIGHBORS = [
    [-1, 0, 0],
    [1, 0, 0],
    [0, -1, 0],
    [0, 1, 0],
    [0, 0, -1],
    [0, 0, 1]
  ]

  def surface
    remaining = cubes.dup

    olds = [].to_set
    currents = remaining.take(1).to_set
    remaining.subtract(currents)
    surface = 6

    loop do
      olds_currents = olds | currents

      puts "WAVE olds: #{olds}"
      puts "WAVE curs: #{currents}"
      news = remaining.take(1)
      puts "WAVE news:"
      pp news

      break if news.empty?

      news.each do |n|
        puts "n: #{n}"
        touching = NEIGHBORS.count do |delta|
          olds_currents.include?(n.neighbor(delta))
        end
        puts "touching: #{touching}"
        ds = 6 - 2 * touching
        puts "ds: #{ds}"
        surface += ds
      end
      puts "Surface now: #{surface}"
      puts

      olds = olds_currents
      currents = news
      remaining.subtract(news)
    end

    surface
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
  text = File.read(ARGV[0] || "input.txt")
  cubes = text.lines.map do |line|
    line =~ /(-?\d+),(-?\d+),(-?\d+)/
    Cube.new($1.to_i, $2.to_i, $3.to_i)
  end

  droplet = Droplet.new(cubes)
  puts "Surface: #{droplet.surface}"
end
