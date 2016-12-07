#!/usr/bin/env ruby
require "set"

instruction_string = File.read("input.txt").chomp
instructions = instruction_string.split /, */

class Taxi
  attr :pos_x
  attr :pos_y

  def initialize
    @pos_x = 0
    @pos_y = 0
    @heading = :north
    @visited = Set.new
    mark
  end

  # @return [[String, Integer]] ["L" or "R", distance]
  def decode(instr)
    [instr[0], instr[1..-1].to_i]
  end

  def go(instr)
    direction, distance = decode(instr)
    turn(direction)
    dx, dy = VECTOR[@heading]
    @pos_x += dx * distance
    @pos_y += dy * distance
  end

  # @return [Boolean] true if we should go on,
  #   false if we have arrived at the duplicate point
  def go_and_mark(instr)
    direction, distance = decode(instr)
    turn(direction)
    dx, dy = VECTOR[@heading]
    distance.times do
      @pos_x += dx
      @pos_y += dy
      if !mark
        return false
      end
    end
    true
  end

  # @return [Boolean] true if we should go on,
  #   false if we have arrived at the duplicate point
  def mark
    if @visited.include? [@pos_x, @pos_y]
      false
    else
      @visited << [@pos_x, @pos_y]
      true
    end
  end
 
  TURN_LEFT = {
    north: :west,
    west:  :south,
    south: :east,
    east: :north,
  }.freeze

  TURN_RIGHT = TURN_LEFT.invert.freeze

  VECTOR = {
    north: [ 0,  1],
    west:  [-1,  0],
    south: [ 0, -1],
    east:  [ 1,  0] 
  }

  # @param where "L" or "R"
  def turn(where)
    case where
    when "L" then @heading = TURN_LEFT.fetch(@heading)
    when "R" then @heading = TURN_RIGHT.fetch(@heading)
    else raise
    end
  end

end

taxi = Taxi.new
instructions.each do |i|
  taxi.go(i)
end

puts "Solution:"
puts taxi.pos_x.abs + taxi.pos_y.abs

taxi2 = Taxi.new
instructions.each do |i|
  taxi2.go_and_mark(i) or break
end

puts "Bonus:"
puts taxi2.pos_x.abs + taxi2.pos_y.abs
