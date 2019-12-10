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

  PIHALF = Math.atan2(1, 0)

  # return [azimuth, manhattan distance]
  def zap_azimuth(fromx, fromy, x, y)
    dy = y - fromy
    dx = x - fromx
    a = Math.atan2(dy, dx)
    az = PIHALF - a
    az += 2 * Math::PI if az < 0
    [az, dy.abs + dx.abs]
  end

  # @return array of pairs
  def zap_order(fromx, fromy)
    result = []

    pairs = Array.new(h) do |y|
      Array.new(w) do |x|
        [x, y, zap_azimuth(fromx, fromy, x, y)]
      end
    end.flatten(1)
pp pairs
    zap_at = {}
    pairs.each do |x, y, polar|
      az, dist = *polar
      next if !map[y][x] || dist == 0
      zap_at[az] ||= []
      zap_at[az] << [x, y, dist] # add one triplet
    end
    zap_at.each_value do |triplets|
      triplets.sort_by!(&:last) # distance
    end
    puts "distance sorted"
pp zap_at

    azs = zap_at.keys.sort
    loop do
      azs.each do |az|
        triplets = zap_at[az]
        next if triplets.nil?

        t = triplets.shift
        result << [t[0], t[1], t[2], az]
        zap_at.delete(az) if triplets.empty?
        return result if zap_at.empty?
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  ms = MonitoringStation.new(File.read("input.txt"))
  puts "Part 1"
  best = ms.best_station
  puts best

  puts "Part 2"
  order = ms.zap_order(best.first[0], best.first[1])
pp order
  xy =  order[199]
  puts 100 * xy[0] + xy[1]
end
