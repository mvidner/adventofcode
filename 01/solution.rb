#!/usr/bin/ruby
input = File.read "input"
puts input.count("(") - input.count(")")
