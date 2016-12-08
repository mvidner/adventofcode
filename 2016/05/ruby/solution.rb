#!/usr/bin/env ruby
require "digest"

input = "wtnhxymk"

def md5(s)
  Digest::MD5.hexdigest(s)
end

def task_md5(key, number)
  md5("#{key}#{number}")
end

puts "Solution:"

password = ""
i = 0
loop do
  hash = task_md5(input, i)
  if hash[0..4] == "00000"
    password += hash[5]
    break if password.size >= 8
  end
  i += 1
end

puts password

puts "Bonus:"

password = "________"
i = 0
loop do
  hash = task_md5(input, i)
  if hash[0..4] == "00000"
    pos = hash[5].ord - "0".ord
    if (0..7).include?(pos) && password[pos] == "_"
      password[pos] = hash[6]
      puts password
      break unless password.include? "_"
    end
  end
  i += 1
end

puts password
