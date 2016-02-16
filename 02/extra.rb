#!/usr/bin/ruby

presents = File.read("input").split(/\n/).map do |present|
  present.split(/x/).map do |size|
    size.to_i
  end
end

module Enumerable
  def sum
    reduce(0, :+)
  end
end

def ribbon_needed(width, height, length)
  bow = width * height * length
  face_circumferences = [
                         2 * (width + height),
                         2 * (height + length),
                         2 * (width + length)
                        ]
  face_circumferences.min + bow
end

individual_ribbon_amounts = presents.map do |w, h, l|
  ribbon_needed(w, h, l)
end

puts individual_ribbon_amounts.sum
