#!/usr/bin/ruby
input = File.read("input").split(/\n/).map(&:chomp)

def nice?(s)
  repeated_pair?(s) && sandwich?(s)
end

def repeated_pair?(s)
  s =~ /(.)(.).*\1\2/
end

def sandwich?(s)
  s =~ /(.).\1/
end

puts input.count {|s| nice?(s) }
