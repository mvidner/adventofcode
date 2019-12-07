#!/usr/bin/env ruby

# Universal Orbit Map, Day 6
class UniversalOrbitMap
  ## @return [Array<Array(String,String)>] [planet name, moon name]
  #attr_reader :map_pairs

  # @return [Hash{String, String}] moon name -> planet name
  attr_reader :centers

  def initialize(input_text)
    map_pairs = input_text.split.map { |l| l.split(")") }
    @centers = {}
    map_pairs.each do |planet, moon|
      raise "moon #{moon} redeclared" if @centers.key?(moon)
      @centers[moon] = planet
    end
  end

  def total_num_orbits
    # object name -> its orbit count
    orbits = {}
    centers.each_key { |moon| compute_orbits(moon, orbits) }
    orbits.values.inject(0, &:+)
  end

  def compute_orbits(moon, orbits)
    return if orbits.key?(moon)

    planet = centers[moon]
    if planet
      compute_orbits(planet, orbits)
      orbits[moon] = orbits[planet] + 1
    else
      puts "The sun is #{moon}"
      orbits[moon] = 0
    end
  end
end

if $PROGRAM_NAME == __FILE__
  uom = UniversalOrbitMap.new(File.read("input.txt"))
  puts "Part 1"
  puts uom.total_num_orbits
end
