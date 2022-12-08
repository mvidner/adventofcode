#!/usr/bin/env ruby

class Map
  attr_reader :rows, :cols

  def initialize(text)
    @grid = text.lines.map do |row|
      row.chomp.chars.map(&:to_i)
    end
    @rows = @grid.size
    @cols = @grid.first.size
    puts rows, cols
  end

  def visible?(r, c)
    # edges are always visible
    return true if r == 0 || r == @rows - 1
    return true if c == 0 || c == @cols - 1

    tree = @grid[r][c]
    # smaller = ->(t) { t < tree }
    
    return true if @grid[r][0, c].all? { |t| t < tree } # from left
    return true if @grid[r][c+1..-1].all? { |t| t < tree } # from right
    return true if @grid[0, r].all? { |row| row[c] < tree } # from top
    return true if @grid[r+1..-1].all? { |row| row[c] < tree } # from bottom

    false
  end

  def scenic(r, c)
    # edges are not scenic
    return 0 if r == 0 || r == @rows - 1
    return 0 if c == 0 || c == @cols - 1

    tree = @grid[r][c]

    # up
    a1 = 0
    (r - 1).downto(0) do |row|
      t = @grid[row][c]
      a1 += 1
      break if t >= tree
    end
    
    # left
    a2 = 0
    (c - 1).downto(0) do |col|
      t = @grid[r][col]
      a2 += 1
      break if t >= tree
    end

    # right
    a3 = 0
    (c + 1).upto(cols-1) do |col|
      t = @grid[r][col]
      a3 += 1
      break if t >= tree
    end

    # down
    a4 = 0
    (r + 1).upto(rows-1) do |row|
      t = @grid[row][c]
      a4 += 1
      break if t >= tree
    end


    p [a1, a2, a3, a4]
    a1 * a2 * a3 * a4
  end

  def count_visible
    total = 0
    rows.times do |r|
      cols.times do |c|
        v = visible?(r, c)
        if v
          print "."
        else
          print "X"
        end
        total +=1 if v
      end
      puts
    end
    total
  end

  def max_scenic
    max = 0
    rows.times do |r|
      cols.times do |c|
        m = scenic(r, c)
        max = m if m > max
      end
    end
    max
  end
end

map = Map.new(File.read(ARGV[0] || "input.txt"))
#puts map.count_visible
puts map.scenic(1, 2)
puts map.max_scenic
