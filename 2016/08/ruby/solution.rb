#!/usr/bin/env ruby

class Display
  OFF = 0
  ON  = 1
  def initialize(x, y)
    @w = x
    @h = y
    @pix = Array.new(@h) { Array.new(@w) { OFF } }
  end

  def count_pixels
    @pix.map { |r| r.count { |c| c == ON } }.reduce(0, :+)
  end

  def perform(instr)
    case instr
    when /rect (\d+)x(\d+)/
      perform_rect($1.to_i, $2.to_i)
    when /rotate row y=(\d+) by (\d+)/
      perform_rrow($1.to_i, $2.to_i)
    when /rotate column x=(\d+) by (\d+)/
      perform_rcol($1.to_i, $2.to_i)
    else
      raise
    end
  end

  def to_s(pix = @pix)
    pix.map { |r| r.map { |c| c == ON ? 'x' : '.' }.join "" }.join "\n"
  end

  private

  def perform_rect(w, h)
    (0 .. h-1).each do |y|
      @pix[y][0, w] = Array.new(w) { ON }
    end
  end

  def perform_rrow(y, count)
    @pix = functional_rot(@pix, @w, y, count)
  end

  def perform_rcol(x, count)
    @pix = functional_rot(@pix.transpose, @h, x, count).transpose
  end

  def functional_rot(pixels, width, row_idx, count)
    # puts to_s(pixels)
    row = pixels[row_idx]
    newrow = row[-count .. -1] + row[0 .. width - count - 1]
    row.replace(newrow)
    # puts "ROT W #{width} I #{row_idx} C #{count}"
    # puts to_s(pixels)
    # puts
    pixels
  end
end

instructions = File.readlines("input.txt")

d1 = Display.new(50, 6)
instructions.each { |i| d1.perform(i) }
puts "Solution:"
puts d1.count_pixels
