#!/usr/bin/env ruby
class PasswordPhilosophy
  def initialize(input_s)
    @input = input_s
  end

  def count_valid_passwords
    @input.lines.count { |l| valid?(l) }
  end

  def count_newly_valid_passwords
    @input.lines.count { |l| newly_valid?(l) }
  end

  def valid?(line)
    line =~ /(\d+)-(\d+) (.): (.*)/
    min = $1.to_i
    max = $2.to_i
    char = $3
    pass = $4

    char_count = tally(pass.chars).fetch(char, 0)
    (min..max).include?(char_count)
  end

  def newly_valid?(line)
    line =~ /(\d+)-(\d+) (.): (.*)/
    first = $1.to_i
    second = $2.to_i
    char = $3
    pass = $4

    first_match = pass[first - 1] == char
    second_match = pass[second - 1] == char

    first_match != second_match
  end

  def tally(enumerable)
    freq = {}
    enumerable.each do |i|
      freq[i] ||= 0
      freq[i] += 1
    end
    freq
  end
end

if $PROGRAM_NAME == __FILE__
  sol = PasswordPhilosophy.new(File.read("input.txt"))
  puts "Part 1"
  puts sol.count_valid_passwords

  puts "Part 2"
  puts sol.count_newly_valid_passwords
end
