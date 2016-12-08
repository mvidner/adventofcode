#!/usr/bin/env ruby

messages = File.readlines("input.txt").map(&:chomp)

histograms = Array.new(messages.first.size) { Hash.new }

messages.each do |m|
  m.each_char.each_with_index do |c, i|
    histogram = histograms[i]
    histogram[c] ||= 0
    histogram[c] += 1
  end
end

puts "Solution:"
histograms.each do |h|
  print h.to_a.max_by {|_char, count| count}.first
end
puts

puts "Part two:"
histograms.each do |h|
  print h.to_a.min_by {|_char, count| count}.first
end
puts
