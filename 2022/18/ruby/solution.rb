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

      # puts "WAVE olds: #{olds}"
      # puts "WAVE curs: #{currents}"
      news = remaining.take(1)
      puts "WAVE news:"
      pp news

      break if news.empty?

      news.each do |n|
        puts "n: #{n}"
        all_neighbors = NEIGHBORS.map do |delta|
          n.neighbor(delta)
        end
        solids, airs = all_neighbors.partition { |c| olds_currents.include?(c) }

        touching = solids.size
        puts "touching: #{touching}"
        ds = 6 - 2 * touching
        puts "ds: #{ds}"
        surface += ds

        airs.each do |a|
          air_neighbors = NEIGHBORS.map do |delta|
            a.neighbor(delta)
          end

          if air_neighbors.all? { |an| olds_currents.include?(an) || news.include?(an)}
            puts "POCKET: #{a}"
            surface -= 6
          end
        end
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
    return if cubes.size == 13 # sample
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
      layers[z].each { |c| rows[c.y][c.x] = "@" }

      xs = (0..21).map { |x| format("%2d", x) }
      puts xs.map { |s| s[0] }.join
      puts xs.map { |s| s[1] }.join

      rows.each_with_index { |r, i| puts "#{r} #{i}" }
      puts
    end
  end

  def outer_surface_by(f1, f2)
    layers = {}
    cubes.each do |c|
      k1 = c.public_send(f1)
      k2 = c.public_send(f2)
      layers[k1] ||= {}
      layers[k1][k2] ||= [].to_set
      layers[k1][k2] << c
    end

    osb = 0
    layers.each do |_k1, inner|
      inner.each do |_k2, values|
        osb +=2 unless values.empty?
      end
    end
    osb
  end

  def outer_surface
    oss = [
      outer_surface_by(:x, :y),
      outer_surface_by(:y, :z),
      outer_surface_by(:x, :z)
    ]
    p oss
    oss.sum
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
  droplet.draw
  puts "Surface: #{droplet.surface}"
  puts "Outer surface: #{droplet.outer_surface}"
end
