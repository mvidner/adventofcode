#!/usr/bin/env ruby

Du = Struct.new(:size, :used, :avail)

grid = []
File.readlines("input.txt").drop(2).each do |line|
  line =~ %r{/dev/grid/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T.*}
  x = $1.to_i
  y = $2.to_i
  size = $3.to_i
  used = $4.to_i
  avail = $5.to_i
  raise "Bad data #{line}" if size != used + avail
  grid[x] ||= []
  grid[x][y] = Du.new(size, used, avail)
end

puts "Solution:"

viable_pairs = 0
grid.size.times do |ax|
  grid[ax].size.times do |ay|
    next if grid[ax][ay].used == 0

    grid.size.times do |bx|
      grid[bx].size.times do |by|
        next if ax == bx && ay == by

        viable_pairs += 1 if grid[ax][ay].used <= grid[bx][by].avail
      end
    end
  end
end

puts viable_pairs

BIG = 400
small_min_size = 999
small_max_used = 0
big_min_used = 999
grid.size.times do |ax|
  grid[ax].size.times do |ay|
    g = grid[ax][ay]
    if g.size > BIG
      if big_min_used > g.used
        big_min_used = g.used
      end
    else
      if small_min_size > g.size
        small_min_size = g.size
      end
      if small_max_used < g.used
        small_max_used = g.used
      end
    end
  end
end

puts "Big min used #{big_min_used}"
puts "Small max used #{small_max_used}"
puts "Small min size #{small_min_size}"
raise "Cannot partition nodes" unless small_max_used < small_min_size && small_min_size < big_min_used
