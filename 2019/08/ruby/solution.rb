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

  def combine(top_layer, bottom_layer)
    # puts "Combining", displayable(top_layer), "and", displayable(bottom_layer)
    r = top_layer.chars.zip(bottom_layer.chars).map do |tc, bc|
      tc == "2" ? bc : tc
    end.join ""
    # puts "Result", displayable(r)
    r
  end

  def displayable(layer)
    layer.chars.each_slice(w).map do |r|
      r.join ""
    end.join "\n"
  end
end

if $PROGRAM_NAME == __FILE__
  img = SpaceImageFormat.new(25, 6, File.read("input.txt").chomp)
  puts "Part 1"
  puts "#{img.nlayers} layers"
  min0layer = (0...img.nlayers)
              .map { |i| [i, img.layer(i).count("0")] }
              .min_by { |_i, count| count }
              .first
  layer = img.layer(min0layer)
  puts layer.count("1") * layer.count("2")

  puts "Part 2"
  composite_layer = "2" * img.w * img.h
  (0...img.nlayers).each_with_object(composite_layer) do |i, clayer|
    # puts "WITH LAYER #{i}"
    composite_layer.replace img.combine(clayer, img.layer(i))
  end
  puts img.displayable(composite_layer).tr("01", " X")
end
