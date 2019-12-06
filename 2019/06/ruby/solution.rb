#!/usr/bin/env ruby

def pairs_from_string(s)
  s.split.map { |l| l.split(")") }
end

def total_num_orbits(map_pairs)
  # moon name -> planet name
  centers = {}
  # object name -> its orbit count
  orbits = {}

  map_pairs.each do |planet, moon|
    raise "moon #{moon} redeclared" if centers.key?(moon)
    centers[moon] = planet
  end
  map_pairs.each do |_planet, moon|
    compute_orbits(moon, centers, orbits)
  end

  orbits.values.inject(0, &:+)
end

def compute_orbits(moon, centers, orbits)
  return if orbits.key?(moon)

  planet = centers[moon]
  if planet
    compute_orbits(planet, centers, orbits)
    orbits[moon] = orbits[planet] + 1
  else
    puts "The sun is #{moon}"
    orbits[moon] = 0
  end
end

if $0 == __FILE__
  puts "Part 1"
  pairs = pairs_from_string(File.read("input.txt"))
  puts total_num_orbits(pairs)
end
