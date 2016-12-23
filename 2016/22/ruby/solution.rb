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
