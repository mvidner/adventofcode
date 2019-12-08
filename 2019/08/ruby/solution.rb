#!/usr/bin/env ruby

# Space Image Format
class SpaceImageFormat
  attr_reader :w, :h, :data, :nlayers

  # @param data [String]
  def initialize(w, h, data)
    @w = w
    @h = h
    @data = data
    @nlayers = @data.size / (@w * @h)
  end

  def layer(i)
    data[i * w * h, w * h]
  end
end

if $PROGRAM_NAME == __FILE__
  img = SpaceImageFormat.new(25, 6, File.read("input.txt").chomp)
  puts "Part 1"
  min0layer = (0...img.nlayers)
              .map { |i| [i, img.layer(i).count("0")] }
              .min_by { |_i, count| count }
              .first
  layer = img.layer(min0layer)
  puts layer.count("1") * layer.count("2")

  puts "Part 2"
  puts "?"
end
