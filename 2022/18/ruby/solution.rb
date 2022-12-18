#!/usr/bin/env ruby
require "set"

Cube = Struct.new(:x, :y, :z) do
  def neighbor(delta)
    Cube.new(x + delta[0], y + delta[1], z + delta[2])
  end
end

class Droplet
  attr_reader :cubes

  attr_reader :outside

  def initialize(cubes)
    @cubes = cubes.to_set
    @outside = [].to_set
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

      # puts "WAVE olds: #{olds}"
      # puts "WAVE curs: #{currents}"
      news = remaining.take(1)
      # puts "WAVE news:"
      # pp news

      break if news.empty?

      news.each do |n|
        # puts "n: #{n}"
        all_neighbors = NEIGHBORS.map do |delta|
          n.neighbor(delta)
        end
        solids, airs = all_neighbors.partition { |c| olds_currents.include?(c) }

        touching = solids.size
        # puts "touching: #{touching}"
        ds = 6 - 2 * touching
        # puts "ds: #{ds}"
        surface += ds
      end
      # puts "Surface now: #{surface}"
      # puts

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

  def stats!
    [:x, :y, :z].each do |field|
      stats_by(field)
    end
  end

  def stats_by(field)
    layers = {}
    cubes.each do |c|
      key = c.public_send(field)
      layers[key] ||= [].to_set
      layers[key] << c
    end

    puts "STATS by #{field}"
    pp layers.map { |l, vals| [l, vals.size] }.sort.to_h
    layers
  end

  def draw
    puts "DRAWING:"

    layers = stats_by(:z)
    (0..21).each do |z|
      puts "Z #{z}"
      rows = 22.times.map do |y|
        void = y % 5 == 0 ? "." : " "
        22.times.map do |x|
          x % 5 == 0 ? "." : void
        end.join
      end
      layers.fetch(z, []).each { |c| rows[c.y][c.x] = "@" }

      xs = (0..21).map { |x| format("%2d", x) }
      puts xs.map { |s| s[0] }.join
      puts xs.map { |s| s[1] }.join

      rows.each_with_index { |r, i| puts "#{r} #{i}" }
      puts
    end
  end

  def fits?(c, min, max)
    (min.x .. max.x).include?(c.x) &&
      (min.y .. max.y).include?(c.y) &&
      (min.z .. max.z).include?(c.z)
  end

  def fill_outside(mins, maxs)
    olds = @outside
    currents = [mins]

    loop do
      # puts "WAVE olds: #{olds}"
      # puts "WAVE curs: #{currents}"
      news = wave(olds, currents) do |cur|
        candidates = NEIGHBORS.map do |delta|
          cur.neighbor(delta)
        end

        candidates.find_all do |can|
          !cubes.include?(can) && fits?(can, mins, maxs)
        end
      end
      # puts "WAVE news:"
      # pp news
      break if news.empty?

      olds = olds | currents
      currents = news
    end

    @outside = olds | currents
  end

  def outer_surface
    fill_outside(Cube.new(-1, -1, -1), Cube.new(22, 22, 22))
    puts "OUTSIDE: #{@outside.size}"

    os = 0
    cubes.each do |c|
      outside_neighbors = NEIGHBORS.count do |delta|
        outside.include?(c.neighbor(delta))
      end
      # puts "#{outside_neighbors} ONs of #{c}"
      os += outside_neighbors
    end
    os
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  cubes = text.lines.map do |line|
    line =~ /(-?\d+),(-?\d+),(-?\d+)/
    Cube.new($1.to_i, $2.to_i, $3.to_i)
  end

  droplet = Droplet.new(cubes)
  # droplet.stats!
  # droplet.draw
  puts "Surface: #{droplet.surface}"
  puts "Outer surface: #{droplet.outer_surface}"
end
