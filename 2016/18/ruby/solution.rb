#!/usr/bin/env ruby

NEXT_CELL = {
  "..." => ".",
  "..^" => "^",
  ".^." => ".",
  ".^^" => "^",
  "^.." => "^",
  "^.^" => ".",
  "^^." => "^",
  "^^^" => "."
}.freeze
def next_cell(three_cells)
#  puts three_cells
  NEXT_CELL.fetch(three_cells).dup
end

def next_row(row)
  nr = next_cell("." + row[0, 2])
  (row.size - 2).times do |i|
#    print "#{i} "
    nr << next_cell(row[i, 3])
  end
  nr << next_cell(row[-2, 2] + ".")
  nr
end

puts "Sample 1:"
safe = 0
row = "..^^."
3.times do
  safe += row.count "."
  puts row
  row = next_row(row)
end
puts "#{safe} safe tiles"
puts

puts "Sample 2:"
safe = 0
row = ".^^.^.^^^^"
10.times do
  safe += row.count "."
  puts row
  row = next_row(row)
end
puts "#{safe} safe tiles"
puts

input = File.read("input.txt").chomp

puts "Part one:"
safe = 0
row = input
40.times do
  safe += row.count "."
  puts row
  row = next_row(row)
end
puts "#{safe} safe tiles"
puts

puts "Part two:"
safe = 0
row = input
400_000.times do
  safe += row.count "."
  row = next_row(row)
end
puts "#{safe} safe tiles"
puts

