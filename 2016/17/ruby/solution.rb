#!/usr/bin/env ruby
require "digest"

def md5(s)
  Digest::MD5.hexdigest(s)
end

$md5_cache = Hash.new

def cached_md5(s)
  $md5_cache[s] ||= md5(s)
end

def cached_hash(salt, i)
  cached_md5("#{salt}#{i}")
end

def door_open(hash_char)
  hash_char >= "b"
end

# upper right corner is [3, 0]
def position(path)
  [
   path.count("R") - path.count("L"),
   path.count("D") - path.count("U")
  ]
end

def udlr_nonwall(path)
  x, y = position(path)
  [
   y > 0,
   y < 3,
   x > 0,
   x < 3
  ]
end

def udlr_open(passcode, path)
  hash = cached_hash(passcode, path)
  hash[0, 4].each_char.map { |c| door_open(c) }
end

MOVES = ["U", "D", "L", "R"].freeze

def possible_moves(passcode, path)
  moves = MOVES.zip(udlr_open(passcode, path), udlr_nonwall(path)).map do |m, a, b|
    (a && b) ? m : nil
  end
  moves.compact
end

def solve(passcode, paths = [""])
  return nil if paths.empty?
  new_paths = []
  paths.each do |path|
    return path if position(path) == [3, 3]

    moves = possible_moves(passcode, path)
    moves.each do |m|
      new_paths << path + m
    end
  end
  solve(passcode, new_paths)
end

puts "Sample 0:"
puts solve("hijkl")

puts "Sample 1:"
puts solve("ihgpwlah")

puts "Sample 2:"
puts solve("kglvqrro")

puts "Sample 3:"
puts solve("ulqzkmiv")

puts "Part one:"
puts solve("udskfozm")

puts

def longest(passcode, path = "", max = 0)
  if position(path) == [3, 3]
    max = path.size if max < path.size
    return max
  end

  moves = possible_moves(passcode, path)
  moves.each do |m|
    max = longest(passcode, path + m, max)
  end
  max
end

puts "Longest path for sample 1:"
puts longest("ihgpwlah")

puts "Longest path for sample 2:"
puts longest("kglvqrro")

puts "Longest path for sample 3:"
puts longest("ulqzkmiv")

puts "Part two:"
puts longest("udskfozm")
