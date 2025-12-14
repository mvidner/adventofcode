#!/usr/bin/env ruby

class Grid
  def initialize(filename)
    text = File.read(filename)
    @lines = text.lines.map(&:chomp)
  end

  # @return [Character] " " if out of bounds
  def get(row, col)
    line = if (0...@lines.length).include?(row)
             @lines[row]
           else
             []
           end
    # puts line
    if (0...line.length).include?(col)
      line[col]
    else
      " "
    end
    # puts "get #{row} #{col} -> '#{c}'"
  end

  def count_neighboring_rolls(row, col)
    [
      [row - 1, col - 1], [row - 1, col], [row - 1, col + 1],
      [row, col - 1], [row, col + 1],
      [row + 1, col - 1], [row + 1, col], [row + 1, col + 1]
    ].filter do |r, c|
      get(r, c) == "@"
    end.count
  end

  def count_accessible_rolls
    sum = 0
    @lines.each_with_index do |line, row|
      line.chars.each_with_index do |char, col|
        have_roll = char == "@"
        count = count_neighboring_rolls(row, col)
        sum += 1 if have_roll && count < 4
        # printf "%3d", count
        # if have_roll
        #   print count < 4 ? "x" : "@"
        # else
        #   print "."
        # end
      end
      # puts
    end
    sum
  end
end

grid = Grid.new(ARGV[0] || "input.txt")
puts "#{grid.count_accessible_rolls} accessible rolls"
