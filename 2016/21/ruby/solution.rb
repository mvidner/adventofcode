#!/usr/bin/env ruby

def rotate_left(password, p)
  password[p .. -1] + password[0, p]
end

def rotate_right(password, p)
  password[-p, p] + password[0 .. (-p - 1)]
end

def rotate_letter(password, c)
  p = password.index(c) or raise "Rotation with a missing letter"
  password = rotate_right(password, p)
  p = (p >= 4) ? 2 : 1
  password = rotate_right(password, p)
  password
end

def scramble(password, instruction, reverse: false)
  case instruction
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
    password = reverse ? rotate_right(password, p) : rotate_left(password, p)
  when /rotate right (\d+) steps?/
    p = $1.to_i
    password = reverse ? rotate_left(password, p) : rotate_right(password, p)

  when /rotate based on position of letter (.)/
    if reverse
      # stupid brute force method
      password.size.times do |p|
        try = rotate_right(password, p)
        return try if rotate_letter(try, $1) == password
      end
    else
      password = rotate_letter(password, $1)
    end
  when /reverse positions (\d+) through (\d+)/
    x, y = $1.to_i, $2.to_i
    password[x .. y] = password[x ..y].reverse

  when /move position (\d+) to position (\d+)/
    x, y = $1.to_i, $2.to_i
    x, y = y, x if reverse
    c = password.slice!(x)
    password.insert(y, c)

  else
    raise "Unrecognized instruction #{i}"
  end
  password
end

instrs = File.readlines("input.txt")


puts "Solution:"
password = "abcdefgh"
instrs.each do |i|
  # puts "#{password}: #{i}"
  password = scramble(password, i)
end
puts password

puts "Reverse:"
password = "fbgdceah"
instrs.reverse_each do |i|
  # puts "#{password}: #{i}"
  password = scramble(password, i, reverse: true)
end
puts password


