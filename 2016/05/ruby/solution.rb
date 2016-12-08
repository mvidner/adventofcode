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
