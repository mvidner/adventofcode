#!/usr/bin/ruby
input = File.read "input"

index = 1
level = 0
input.each_char do |c|
  level += 1 if c == "("
  level -= 1 if c == ")"

  if level < 0
    puts index
    exit
  end

  index += 1
end
