#!/usr/bin/env ruby
require "digest"

def md5(s)
  Digest::MD5.hexdigest(s)
end

$md5_cache = Hash.new

def cached_md5(s)
  $md5_cache[s] ||= md5(s)
end

def hash(salt, i)
  md5("#{salt}#{i}")
end

def cached_hash(salt, i)
  cached_md5("#{salt}#{i}")
end

# return nil or the one character repeated
def has_triple?(s)
  if s =~ /(.)\1{2}/
    $1
  end
end

def solve(salt)
  keys_found = 0
  i = 0
  loop do
    h = cached_hash(salt, i)
    if (c = has_triple?(h))
      if ((i + 1)..(i + 1000)).any? { |j| cached_hash(salt, j).include?(c * 5) }
        keys_found += 1
      end
    end

    break if keys_found == 64

    i += 1
  end
  puts i
end

solve("abc")
solve("qzyelonm")
