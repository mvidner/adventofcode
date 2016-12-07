#!/usr/bin/env ruby
require "set"

instructions = File.readlines("input.txt").map(&:chomp)

class Array
  def strict_at(i)
    return nil if i < 0
    at(i)
  end
end

class Keypad
  attr :pos_x
  attr :pos_y

  VECTOR = {
    "U" => [ 0,  1],
    "L" => [-1,  0],
    "D" => [ 0, -1],
    "R" => [ 1,  0] 
  }.freeze


  def initialize(x, y, keys)
    @pos_x = x
    @pos_y = y
    @keys  = keys
  end

  def key(x = @pos_x, y = @pos_y)
    # will return nil if we're out of bounds
    row = @keys.strict_at(@keys.size - 1 - y)
    return nil if row.nil?
    row.strict_at(x)
  end

  def go(instr)
    # puts
    instr.each_char do |c|
      dx, dy = VECTOR[c]
      if key(@pos_x + dx, @pos_y + dy) != nil
        @pos_x += dx
        @pos_y += dy
      end
      # print "#{c}->[#{pos_x},#{pos_y}] "
    end
  end

  def solution(instrs)
    instrs.map do |i|
      go(i)
      key
    end.join ""
  end
end

puts "Solution:"
pad1 = Keypad.new(1, 1, [
                         [1, 2, 3],
                         [4, 5, 6],
                         [7, 8, 9]
                        ].freeze)
puts pad1.solution(instructions)

puts "Bonus:"
pad2 = Keypad.new(0, 2, [
                           [nil, nil, "1", nil, nil],
                           [nil, "2", "3", "4", nil],
                           ["5", "6", "7", "8", "9"],
                           [nil, "A", "B", "C", nil],
                           [nil, nil, "D", nil, nil],
                           ].freeze)
puts pad2.solution(instructions)
