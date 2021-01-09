#!/usr/bin/env ruby
class PasswordPhilosophy
  def initialize(input_s)
    @input = input_s
  end

  def count_valid_passwords
    @input.lines.count { |l| valid?(l) }
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

  #puts "Part 2"
  #puts sol
end
