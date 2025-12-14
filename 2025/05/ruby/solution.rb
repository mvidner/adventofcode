#!/usr/bin/env ruby

class Ingredients
  def self.from_file(filename)
    text = File.read(filename)
    fresh_text, available_text = text.split("\n\n")

    fresh = fresh_text.lines.map do |line|
      from, to = line.split("-")
      # an inclusive Range
      (from.to_i..to.to_i)
    end

    available = available_text.lines.map(&:to_i)

    new(fresh, available)
  end

  def initialize(fresh, available)
    @fresh = fresh
    @available = available
    # p self
  end

  # an ingredient is fresh if it falls into any of the fresh ranges
  def fresh?(ing)
    @fresh.any? { |f| f.include?(ing) }
  end

  def count_fresh
    @available.count { |a| fresh?(a) }
  end

  def total_fresh
    # Well duh, the ranges can overlap, so this is wrong:
    # @fresh.map { |f| f.size }.sum

    all_fresh = IntegerSet.new
    @fresh.each do |f|
      all_fresh.merge(f)
    end

    all_fresh.size
  end
end

# copied from 2022/15
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

ingredients = Ingredients.from_file(ARGV[0] || "input.txt")

puts "#{ingredients.count_fresh} fresh ingredients"

puts "#{ingredients.total_fresh} total fresh ingredients"
