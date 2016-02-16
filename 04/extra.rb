#!/usr/bin/ruby

require "digest"

$input = "bgvyzdsv"

def md5(s)
  Digest::MD5.hexdigest(s)
end

def task_md5(key, number)
  md5("#{key}#{number}")
end

def good_number?(number)
  task_md5($input, number)[0..5] == "000000"
end

i = 0
while !good_number?(i)
  i += 1
end
puts i

