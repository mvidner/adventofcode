#!/usr/bin/env ruby

class C
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
end
