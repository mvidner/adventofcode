#!/usr/bin/env ruby

def dragon_step(s)
  s + "0" + s.reverse.tr("01", "10")
end

def checksum(s)
  if s.size.odd?
    s
  else
    half = s.size / 2
    cs = ""
    half.times do |i|
      cs << ((s[2 * i] == s[2 * i + 1]) ? "1" : "0")
    end
    checksum(cs)
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
