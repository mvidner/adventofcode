#!/usr/bin/env ruby

text = File.read(ARGV[0] || "input.txt")
lines = text.lines.map do |line|
  line.chomp.split
end

operations = lines.pop
numbers = lines.map do |line|
  line.map(&:to_i)
end

results = operations.each_with_index.map do |op_char, i|
  operands = numbers.map { |nums| nums[i] }

  case op_char
  when "+"
    operands.reduce(0, &:+)
  when "*"
    # operands.product weirds out
    operands.reduce(1, &:*)
  else
    raise
  end
end

puts "Sum of results is #{results.sum}"

char_matrix = text.lines.map { |l| l.chomp.chars }.transpose
# pp char_matrix

sum = 0
numbers = []
char_matrix.reverse_each do |chars|
  op_char = chars.pop
  number_text = chars.join
  next if number_text !~ /[0-9]/

  numbers << number_text.to_i

  case op_char
  when " "
    # do nothing
  when "+"
    sum += numbers.reduce(0, &:+)
    numbers = []
  when "*"
    sum += numbers.reduce(1, &:*)
    numbers = []
  else
    raise
  end
end

puts "Octopodal sum of results is #{sum}"
