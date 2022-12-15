#!/usr/bin/env ruby

Point = Struct.new(:x, :y)
Sensor = Struct.new(:sensor, :beacon)

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
  end

  def count_covered!(y:)
    puts "Covered at y=#{y}: #{count_covered(y: y)}"
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")

  bxz = Beacons.parse(text)
  # pp bxz
  count_covered!(20)
  count_covered!(2_000_000)
end
