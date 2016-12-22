#!/usr/bin/env ruby

DISK_SIZE = 272
input = "10111100110001111"

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

puts "Solution:"

disk = input
while disk.size < DISK_SIZE
  disk = dragon_step(disk)
end
disk = disk[0, DISK_SIZE]

puts checksum(disk)
