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

data.each do |d|
  position = (position + d) % 100
  at_zero_count +=1 if position.zero?
end

puts "#{at_zero_count} times zero position"
