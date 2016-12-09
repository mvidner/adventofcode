#!/usr/bin/env ruby
input = File.read("input.txt").chomp
p input

def decompress(s)
  out = ""
  loop do
    # puts "#{s.size}: #{s[0, 10]}..."
    case s
    when ""
      break
    when /\A\((\d+)x(\d+)\)/
      len = $1.to_i
      times = $2.to_i
      # puts "EXPANDED LEN #{len}, TIMES #{times} "
      s = s[$&.size .. -1]      
      out += (s[0, len]* times)
      s = s[len .. -1]
    when /\A[^(]*/
      out += $&
      s = s[$&.size .. -1]
      # puts "COPIED #{$&.size}"
    else
      raise "WTF"
    end
  end
  out
end

puts "Part A:"
puts decompress(input).size

# out is just the size of the decompressed data
def recursively_decompressed_size(s)
  out = 0
  loop do
    case s
    when ""
      break
    when /\A\((\d+)x(\d+)\)/
      len = $1.to_i
      times = $2.to_i
      s = s[$&.size .. -1]      
      out += (recursively_decompressed_size(s[0, len])* times)
      s = s[len .. -1]
    when /\A[^(]*/
      out += $&.size
      s = s[$&.size .. -1]
    else
      raise "WTF"
    end
  end
  out
end

puts "Part B:"
puts recursively_decompressed_size(input)
