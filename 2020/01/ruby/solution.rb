#!/usr/bin/env ruby
require "set"

class ReportRepair
  def initialize(input)
    @entries = input.split.map(&:to_i)
  end

  def find_2020
    # since the entries are bounded we can use them as members in a set
    seen = Set.new

    @entries.each do |e|
      other = 2020 - e
      if seen.include?(other)
        return e * other
      end
      seen << e
    end
    raise "No matching pair found"
  end
end

if $PROGRAM_NAME == __FILE__
  rr = ReportRepair.new(File.read("input.txt"))
  puts "Part 1"
  puts rr.find_2020
end
