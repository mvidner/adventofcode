#!/usr/bin/env ruby

class C
  attr_reader :value

  def initialize(val)
    @value = val
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
end
