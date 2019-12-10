#!/usr/bin/env ruby

# Asteroid monitoring station
class MonitoringStation
  # @return [Array<Array<Boolean>>] true for asteroids
  attr_accessor :map
  # @return [Integer]
  attr_reader :w, :h

  def initialize(map_string)
    @map = map_string.lines.map do |line|
      line.chomp.chars.map do |char|
        char == "#"
      end
    end
    @w = map.first.size
    @h = map.size
    raise "Not a rectangle" unless map.all? { |row| row.size == w }
  end

  # is there an asteroid at [x,y] which is visible from [fromx, fromy]
  def visible?(fromx, fromy, x, y)
    return false unless map[y][x]
    dx = x - fromx
    dy = y - fromy
    g = dx.gcd(dy)
    return false if g.zero? # seeing ourselves does not count
    return true if g == 1
    mx = dx / g
    my = dy / g
    (1..g - 1).none? { |k| map[fromy + k * my][fromx + k * mx] }
  end

  # count other asteroids visible from x, y (even if we have no asteroid)
  def count_visible(x, y)
    sum = 0
    h.times do |oy|
      w.times do |ox|
        sum += 1 if visible?(x, y, ox, oy)
      end
    end
    sum
  end

  def best_station
    bestx = nil
    besty = nil
    best = 0
    h.times do |y|
      w.times do |x|
        next unless map[y][x]
        now = count_visible(x, y)
        next unless best < now
        best = now
        bestx = x
        besty = y
      end
    end
    [[bestx, besty], best]
  end
end

if $PROGRAM_NAME == __FILE__
  ms = MonitoringStation.new(File.read("input.txt"))
  puts "Part 1"
  p ms.best_station
end
