#!/usr/bin/env ruby

class Grid
  def self.from_file(filename)
    text = File.read(filename)
    lines = text.lines.map(&:chomp)
    new(lines)
  end

  def initialize(lines)
    @lines = lines
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

  # @return [Grid] a new Grid with the accessible rolls removed
  def remove_accessible_rolls
    new_lines = Array.new(@lines.size)

    @lines.each_with_index do |line, row|
      new_line = " " * line.size

      line.chars.each_with_index do |char, col|
        if char == "@"
          count = count_neighboring_rolls(row, col)
          if count < 4
            new_line[col] = "x"
          else
            new_line[col] = "@"
          end
        else
          new_line[col] = "."
        end
      end
      new_lines[row] = new_line
    end
    Grid.new(new_lines)
  end

  def print
    puts @lines
  end
end

grid = Grid.from_file(ARGV[0] || "input.txt")
grid.print
puts "#{grid.count_accessible_rolls} accessible rolls"

total_accessible_rolls = 0
i = 0
loop do
  accessible_rolls = grid.count_accessible_rolls
  break if accessible_rolls == 0

  total_accessible_rolls += accessible_rolls
  i += 1
  grid = grid.remove_accessible_rolls
end
puts "#{total_accessible_rolls} total accessible rolls in #{i} iterations"
