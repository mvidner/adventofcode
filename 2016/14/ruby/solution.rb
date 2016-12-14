#!/usr/bin/env ruby
require "digest"

def md5(s)
  Digest::MD5.hexdigest(s)
end

$md5_cache = Hash.new

def cached_md5(s)
  $md5_cache[s] ||= md5(s)
end

def stretched_md5(s)
  2017.times do
    s = cached_md5(s)
  end
  s
end

def hash(salt, i)
  md5("#{salt}#{i}")
end

def cached_hash(salt, i)
  cached_md5("#{salt}#{i}")
end

def stretched_hash(salt, i)
  stretched_md5("#{salt}#{i}")
end

# return nil or the one character repeated
def has_triple?(s)
  if s =~ /(.)\1{2}/
    $1
  end
end

def solve(salt, hash_name = :hash)
  keys_found = 0
  i = 0
  loop do
    h = send(hash_name, salt, i)
    if (c = has_triple?(h))
      r = (i + 1)..(i + 1000)
      if r.any? { |j| send(hash_name, salt, j).include?(c * 5) }
        keys_found += 1
      end
    end

    break if keys_found == 64

    i += 1
  end
  puts i
end

def time_it
  t0 = Time.now
  yield
  t1 = Time.now
  printf("It took %.4g seconds.\n", t1 - t0)
end

sample = "abc"
input  = "qzyelonm"
time_it { solve(sample, :hash) }
time_it { solve(input,  :hash) }

time_it { solve(sample, :cached_hash) }
time_it { solve(input,  :cached_hash) }

time_it { solve(sample, :stretched_hash) }
time_it { solve(input,  :stretched_hash) }
