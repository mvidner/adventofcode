#!/usr/bin/env ruby

def dragon_step(s)
  s + "0" + s.reverse.tr("01", "10")
end

def checksum(s)
  if s.size.odd?
    s
  else
    s = s.each_char.each_slice(2).map do |a, b|
      (a == b) ? "1" : "0"
    end.join("")
    checksum(s)
  end
end

def solve(input, disk_size)
  disk = input
  while disk.size < disk_size
    disk = dragon_step(disk)
  end
  checksum(disk[0, disk_size])
end

input = "10111100110001111"

puts "Solution:"
puts solve(input, 272)

puts "Part two:"
puts solve(input, 35651584)
