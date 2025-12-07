#!/usr/bin/env ruby
text = File.read(ARGV[0] || "input.txt")

lines = text.lines
first = lines.shift
# Set of integer positions
beams = Set.new
beams.add first.index("S")

splits = 0

lines.each do |l|
  next_beams = Set.new
  l.chars.each_with_index do |c, i|
    next unless beams.include?(i)

    case c
    when "."
      next_beams.add(i)
    when "^"
      next_beams.add(i - 1)
      next_beams.add(i + 1)
      splits += 1
    when "\n"
      # do nothing
    else
      raise "unexpected character #{c.inspect}"
    end
  end
  beams = next_beams
end

puts "Split count: #{splits}"
