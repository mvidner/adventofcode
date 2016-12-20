#!/usr/bin/env ruby
require "set"

all = (0 ... (2 ** 32))

rules = File.readlines("input.txt").map do |line|
  line =~ /(\d+)-(\d+)/
  low = $1
  high = $2
  raise "Invalid range input" if high < low
  (low .. high)
end

# a non-overlapping set of Ranges
class RangeSet
  # it starts with a single Range
  def initialize(range)
    @set = Set.new
    @set << range
  end

  def subtract(range)
    b = range.be
  end
end

# extend it
class Range
  def subtract(other)
    raise ArgumentError unless other.is_a? Range
    raise ArgumentError unless exclude_end? && other.exclude_end?

    if other.begin < self.begin
      if other.end < self.begin
        self
      elsif other.end < self.end # <= ?

    
  end

  def to_open
    if exclude_end?
      self
    else
      (self.begin ... self.end.succ)
    end
  end

end
