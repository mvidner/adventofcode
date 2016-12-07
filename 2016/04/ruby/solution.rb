#!/usr/bin/env ruby

RX = /\A([a-z-]+)-([0-9]+)\[([a-z]+)\]/

def parse_room(r)
  m = RX.match(r)
  [m[1], m[2].to_i, m[3]]
end

rooms = File.readlines("input.txt").map {|r| parse_room(r) }

def calc_checksum(id)
  # puts
  # puts "CKS #{id}"
  counts = {}
  id.each_char do |c|
    next if c == "-"
    counts[c] ||= 0
    counts[c] += 1
  end
  winners = counts.to_a.sort_by { |c, freq| [-freq, c] }.take(5)
  # p winners
  winners.map { |c, _freq| c}.join ""
end

def is_room?(id, _index, checksum)
  calc_checksum(id) == checksum
end

puts "Solution:"
real_rooms = rooms.find_all { |r| is_room?(*r) }
puts "(#{real_rooms.size} of #{rooms.size} rooms are real)"
puts real_rooms.map { |r| r[1]}.reduce(0, :+)

def decrypt_letter(c, num)
  return " " if c == "-"
  ((((c.ord - "a".ord) + num) % 26) + "a".ord).chr
end

def decrypt(room, index, _checksum)
  room.each_char.map {|c| decrypt_letter(c, index)}.join ""
end

puts "Bonus:"
real_rooms.each do |r|
  descr = decrypt(*r)
  next unless descr =~ /north/i
  puts r[1]
end
