#!/usr/bin/env ruby

Point = Struct.new(:x, :y, :z) do
  include Comparable

  # lexicographic ordering
  def <=>(other)
    ret = x <=> other.x
    return ret if ret != 0

    ret = y <=> other.y
    return ret if ret != 0

    z <=> other.z
  end

  def distance_squared(other)
    (x - other.x)**2 + (y - other.y)**2 + (z - other.z)**2
  end

  def distance(other)
    Math.sqrt(distance_squared(other))
  end
end

class Points
  def self.from_file(filename)
    text = File.read(filename)
    points = text.lines.map do |line|
      x, y, z = line.split(",").map(&:to_i)
      Point.new(x, y, z)
    end
    new(points)
  end

  # We only track circuits of more than one point
  # @return [Array<Set<Point>>]
  attr_reader :circuits

  # from a Point to (reference to) a circuit Set
  # @return [Hash<Point, Integer>]
  attr_reader :points_to_circuits

  def initialize(points)
    @points = points
    calculate_distances
    @circuits = []
    @points_to_circuits = {}
  end

  def calculate_distances
    @sq_distances = []

    @points.each do |a|
      @points.each do |b|
        d = a.distance_squared(b)
        @sq_distances << [d, a, b] if a < b
      end
    end

    @sq_distances.sort!
  end

  # Connect the next pair of closest points that aren't already connected
  # OK, I thought they might count this way, but no
  def next_connection
    loop do
      break if try_next_connection
    end
    # pp @circuits
    pp self
  end

  # Take the next shortest distance and try connecting it
  # @return true if a connection was made, false if the points were already connected
  def try_next_connection
    _d, a, b = @sq_distances.shift # TODO: what if exhausted

    ca = circuits.find { |c| c.include?(a) }
    cb = circuits.find { |c| c.include?(b) }

    if ca.nil? && cb.nil?
      puts "Add a new circuit" if $DEBUG

      c = [a, b].to_set
      @circuits << c
      @points_to_circuits[a] = c
      @points_to_circuits[b] = c
    elsif !ca.nil? && !cb.nil?
      if ca == cb
        puts "Same circuit" if $DEBUG
        return false
      end
      puts "Merge two circuits" if $DEBUG

      ca.merge(cb)
      @circuits.delete(cb)
      cb.each do |point|
        @points_to_circuits[point] = ca
      end
    elsif ca.nil?
      puts "Add a to cb" if $DEBUG
      cb << a
      @points_to_circuits[a] = cb
    else # cb.nil?
      puts "Add b to ca" if $DEBUG
      ca << b
      @points_to_circuits[b] = ca
    end

    true
  end

  # multiply the sizes of the `num` largest circuits
  def print_circuit_signature(num)
    sizes = @circuits.map(&:size).sort.reverse.take(num)
    puts "#{num} largest circuit sizes #{sizes.inspect}, multiplied: #{sizes.reduce(1, &:*)}"
  end
end

if $PROGRAM_NAME == __FILE__
  ps = Points.from_file(ARGV[0] || "input.txt")
  count = 1000
  count = 10 if ARGV[0] == "sample.txt"

  count.times do |i|
    puts "Connection #{i + 1}" if $DEBUG
    ps.try_next_connection
  end

  ps.print_circuit_signature(3)
end
