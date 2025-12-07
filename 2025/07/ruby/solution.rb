#!/usr/bin/env ruby
text = File.read(ARGV[0] || "input.txt")

lines = text.lines
first = lines.shift
# number of paths each position can be reached; 0 if not given
pathways = []
start = first.index("S")
pathways[start] = 1
splits = 0

lines.each do |l|
  next_pathways = []

  l.chars.each_with_index do |c, i|
    next unless (pathways[i] || 0) > 0

    case c
    when "."
      next_pathways[i] ||= 0
      next_pathways[i] += pathways[i] || 0
    when "^"
      next_pathways[i - 1] ||= 0
      next_pathways[i - 1] += pathways[i] || 0
      next_pathways[i + 1] ||= 0
      next_pathways[i + 1] += pathways[i] || 0
      splits += 1
    when "\n"
      # do nothing
    else
      raise "unexpected character #{c.inspect}"
    end
  end
  p next_pathways
  pathways = next_pathways
end

puts "Split count: #{splits}"
puts "Pathways: #{pathways.compact.sum}"