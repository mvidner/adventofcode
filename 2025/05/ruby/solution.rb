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
end

ingredients = Ingredients.from_file(ARGV[0] || "input.txt")

puts "#{ingredients.count_fresh} fresh ingredients"
