#!/usr/bin/env ruby

# Hmm,
# This is a good puzzle to use unit tests because of the many+1 opportunities
# for off-by-one errors

EMPTY_RANGE = (0...0)
# limited to inclusive ranges, and the special (0...0) empty exclusive range
def range_intersection(a, b)
  return EMPTY_RANGE if a == EMPTY_RANGE || b == EMPTY_RANGE

end

class IntegerSet
  attr_reader :ranges

  def initialize(ranges = [])
    # inclusive non-overlapping ranges, ordered
    @ranges = ranges
  end

  # @param other [Enumerable,IntegerSet]
  # def union(other); end

  def merge(range)
    # puts "merge(#{range} into #{@ranges.inspect})"
    return self if range.size == 0

    @new = [range]
    @ranges.each do |r|
      last = @new.pop
      merged_pair = merge2(r, last)
      @new.push(* merged_pair)
    end

    @ranges = @new
    self
  end

  # @return array of ranges, having 1 or 2 elements
  def merge2(r1, r2)
    if r1.begin > r2.begin
      r1, r2 = r2, r1
    end
    # r1.begin is minimal

    # not overlapping?
    if r2.begin > r1.end
      [r1, r2]
    else
      [(r1.begin .. [r1.end, r2.end].max)]
    end
  end

  # @return array of ranges, having 0 or 1 elements
  def intersect2(r1, r2)
    # print "intersect2 #{r1} and #{r2}"
    if r1.begin > r2.begin
      r1, r2 = r2, r1
    end
    # r1.begin is minimal

    # not overlapping?
    ret = if r2.begin > r1.end
      []
    else
      [([r1.begin, r2.begin].max .. [r1.end, r2.end].min)]
    end
    # puts "-> #{ret}"
    ret
  end

  # @return {IntegerSet}
  def intersection(range)
    # puts "intersection #{range} and #{@ranges}"
    new_new = @ranges.map do |r|
      intersect2(r, range)
    end
    ranges = new_new.flatten(1)

    IntegerSet.new(ranges)
  end

  def size
    @ranges.map(&:size).sum
  end
end

Point = Struct.new(:x, :y)
Sensor = Struct.new(:sensor, :beacon) do
  def distance
    @distance ||= (sensor.x - beacon.x).abs + (sensor.y - beacon.y).abs
  end

  # @return [Range] range of covered *x*s at given y; or an empty range
  def at_y(y)
    y_distance = (sensor.y - y).abs
    return EMPTY_RANGE if y_distance > distance
    dx = distance - y_distance
    (sensor.x - dx .. sensor.x + dx)
  end
end

class Beacons
  FMT = /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
  def self.parse(text)
    sensors = text.lines.map do |line|
      line =~ FMT or raise
      Sensor.new(Point.new($1.to_i, $2.to_i), Point.new($3.to_i, $4.to_i))
    end

    new(sensors)
  end

  def initialize(sensors)
    @sensors = sensors
  end

  def count_covered(y:)
    covered = IntegerSet.new

    @sensors.each do |s|
      aty = s.at_y(y)
      covered.merge(aty)
    end

    num_beacons = @sensors.map { |s| s.beacon }.find_all { |b| b.y == y }.uniq.size
    # p :n, num_beacons
    covered.size - num_beacons
  end

  def count_covered!(y:)
    puts "Covered at y=#{y}: #{count_covered(y: y)}"
  end

  def find_distress(limit:)
    limit.times do |y|
      covered = IntegerSet.new

      @sensors.each do |s|
        aty = s.at_y(y)
        covered.merge(aty)
      end

      limited = covered.intersection(0 .. limit)
      if limited.size == limit
        # got it! find x
        if limited.ranges.size == 2
          x = limited.ranges.first.end + 1
          return Point.new(x, y)
        else
          raise "tough luck at #{y}"
        end
      end
      puts "#{y}: #{limited.size}" if y % 100_000 == 0
    end
    Point.new(-1, -1)
  end

  def find_distress!(limit:)
    pos = find_distress(limit: limit)
    puts "Signal freq: #{pos.x * 4_000_000 + pos.y}"
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")

  bxz = Beacons.parse(text)
  # pp bxz
  bxz.count_covered!(y: 10)
  bxz.find_distress!(limit: 20)

  bxz.count_covered!(y: 2_000_000)
  bxz.find_distress!(limit: 4_000_000)
end
