#!/usr/bin/env ruby
require "set"

class ReportRepair
  def initialize(input)
    @entries = input.split.map(&:to_i)
  end

  def find_2020
    a, b = find_pair(2020)
    a * b
  end

  def find_pair(sum)
    # since the entries are bounded we can use them as members in a set
    seen = Set.new

    @entries.each do |e|
      other = sum - e
      return [e, other] if seen.include?(other)

      seen << e
    end
    raise "No matching pair found"
  end

  def find_triplet(sum)
    # brute force for a change
    @entries.each do |a|
      @entries.each do |b|
        @entries.each do |c|
          return [a, b, c] if a + b + c == sum
        end
      end
    end
    raise "No matching triplet found"
  end
end

if $PROGRAM_NAME == __FILE__
  rr = ReportRepair.new(File.read("input.txt"))
  puts "Part 1"
  puts rr.find_2020

  puts "Part 2"
  a, b, c = rr.find_triplet(2020)
  puts a * b * c
end
