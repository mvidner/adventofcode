#!/usr/bin/env ruby

instrs = File.readlines("input.txt")

password = "abcdefgh"

instrs.each do |i|
  # puts "#{password}: #{i}"

  case i
  when /swap position (\d+) with position (\d+)/
    x, y = $1.to_i, $2.to_i
    cx = password[x]
    cy = password[y]
    password[x] = cy
    password[y] = cx

  when /swap letter (.) with letter (.)/
    password.tr!($1 + $2, $2 + $1)

  when /rotate left (\d+) steps?/
    p = $1.to_i
    password = password[p .. -1] + password[0, p]
  when /rotate right (\d+) steps?/
    p = $1.to_i
    password = password[-p, p] + password[0 .. (-p - 1)]

  when /rotate based on position of letter (.)/
    p = password.index($1) or raise "Rotation with a missing letter"
    password = password[-p, p] + password[0 .. (-p - 1)]
    p = (p >= 4) ? 2 : 1
    password = password[-p, p] + password[0 .. (-p - 1)]

  when /reverse positions (\d+) through (\d+)/
    x, y = $1.to_i, $2.to_i
    password[x .. y] = password[x ..y].reverse

  when /move position (\d+) to position (\d+)/
    x, y = $1.to_i, $2.to_i
    c = password.slice!(x)
    password.insert(y, c)

  else
    raise "Unrecognized instruction #{i}"
  end
end

puts "Solution:"
puts password
