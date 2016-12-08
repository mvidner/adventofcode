#!/usr/bin/env ruby

addresses = File.readlines("input.txt").map(&:chomp)

def has_abba?(s)
  s =~ /([a-z])([a-z])(\2)(\1)/ && $1 != $2
end

HN_RX = /\[[^\]]*\]/

def supports_tls?(a)
  without_hypernet = a.gsub(HN_RX, "[]")
  just_hypernet = a.scan(HN_RX).join ""
  has_abba?(without_hypernet) && ! has_abba?(just_hypernet)
end

puts "Part A:"
puts addresses.count { |a| supports_tls?(a) }

def find_abas(a)
  # cannot use String#scan(Regexp)
  # because it would not catch overlapping matches
  abas = a.each_char.each_cons(3).find_all do |a, b, c|
    a == c && a != b
  end.map do |triple|
    triple.join ""
  end
  # puts "ABAS for #{a}: #{abas.inspect}"
  abas
end

def supports_ssl?(a)
  without_hypernet = a.gsub(HN_RX, "[]")
  just_hypernet = a.scan(HN_RX).join ""

  abas = find_abas(without_hypernet)
  abas.any? do |aba|
    bab = aba[1] + aba[0] + aba[1]
    just_hypernet.include?(bab)
  end
end

puts "Part B:"
puts addresses.count { |a| supports_ssl?(a) }
