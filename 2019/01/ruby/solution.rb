#!/usr/bin/env ruby
masses = File.readlines("input.txt").map {|s| Integer(s) }

def fuel_from_mass(m)
  [0, (m.to_i / 3) - 2].max
end

puts masses.map { |m| fuel_from_mass(m) }.inject(0, &:+)

def iterated_fuel_from_mass(m)
  parts = []
  loop do
    delta = fuel_from_mass(m)
    break if delta.zero?
    parts << delta
    m = delta
  end
  parts.inject(0, &:+)
end

puts masses.map { |m| iterated_fuel_from_mass(m) }.inject(0, &:+)
