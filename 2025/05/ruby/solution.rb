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
  # inclusive non-overlapping ranges, ordered (sorted)
  attr_reader :ranges

  def initialize(ranges = [])
    @ranges = ranges
  end

  def merge(range)
    # puts "merge(#{range} into #{@ranges.inspect})"
    return self if range.size == 0

    # Key insight: as @ranges and @new are sorted,
    # all items of @new come before the items of @ranges,
    # except for their last and first items respectively,
    # and that is where the individual merge2 is called.

    # @new maintains the same invariant as @ranges
    @new = [range]

    # This is the only time where the `r` to be merged
    # may be entirely smaller than the last element of `@new`.

    @ranges.each do |r|
      last = @new.pop
      merged_pair = merge2(r, last)
      @new.push(* merged_pair)

      # From now on, the incoming `r` will always be no smaller
      # than the beginning of the last range in `@new`
    end

    @ranges = @new
    self
  end

  def size
    @ranges.map(&:size).sum
  end

  private

  # @return a sorted array of ranges, having 1 or 2 elements
  def merge2(r1, r2)
    r1, r2 = r2, r1 if r1.begin > r2.begin
    # r1.begin is minimal

    # not overlapping?
    if r2.begin > r1.end
      [r1, r2]
    else
      [(r1.begin .. [r1.end, r2.end].max)]
    end
  end
end

ingredients = Ingredients.from_file(ARGV[0] || "input.txt")

puts "#{ingredients.count_fresh} fresh ingredients"

puts "#{ingredients.total_fresh} total fresh ingredients"
