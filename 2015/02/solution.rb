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

def paper_needed(width, height, length)
  face_areas = [width * height, height * length, width * length]
  slack = face_areas.min
  face_areas.sum * 2 + slack
end

individual_paper_amounts = presents.map do |w, h, l|
  paper_needed(w, h, l)
end

puts individual_paper_amounts.sum
