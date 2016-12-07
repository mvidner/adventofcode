#!/usr/bin/env ruby
require "set"

instructions = File.readlines("input.txt").map(&:chomp)

class Keypad
  # we model the keypad with Cartesian coordinates, with "5" at [0, 0]
  attr :pos_x
  attr :pos_y

  VECTOR = {
    "U" => [ 0,  1],
    "L" => [-1,  0],
    "D" => [ 0, -1],
    "R" => [ 1,  0] 
  }.freeze


  def initialize
    @pos_x = 0
    @pos_y = 0
  end

  KEYS = [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9]
         ].freeze

  def key
    KEYS[1 - @pos_y][@pos_x + 1]
  end

  def clamp(x)
    if x < -1
      -1
    elsif x > 1
      1
    else
      x
    end
  end

  def go(instr)
    instr.each_char do |c|
      dx, dy = VECTOR[c]
      @pos_x = clamp(@pos_x + dx)
      @pos_y = clamp(@pos_y + dy)
    end
  end
end

puts "Solution:"

pad1 = Keypad.new
instructions.each do |i|
  pad1.go(i)
  print pad1.key
end
print "\n"

puts "Bonus:"
puts "?"
