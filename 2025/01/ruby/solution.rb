#!/usr/bin/env ruby
text = File.read(ARGV[0] || "input.txt")

data = text.lines.map do |line|
  next if line.empty?

  case line[0]
  when "R"
    Integer(line[1..-1])
  when "L"
    -Integer(line[1..-1])
  else
    raise "Unexpected input line: #{line.inspect}"
  end
end.compact

position = 50
at_zero_count = 0
at_zero_clicks = 0

data.each do |d|
  zero_clicks = ((position + d) / 100.0).floor.abs
  at_zero_clicks += zero_clicks

  position = (position + d) % 100
  at_zero_count +=1 if position.zero?
end

puts "#{at_zero_count} times zero position"
puts "#{at_zero_clicks} times clicked at zero"
