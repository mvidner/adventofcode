#!/usr/bin/env ruby

class Mixer
  def initialize(numbers)
    @numbers = numbers
    @size = @numbers.size

    # new_pos[a] == b means that
    # the number that was at *a* at the start is now at *b*
    @new_pos = (0 ... @size).to_a
  end

  def mix
    puts "Initial arrangement:" if tracing?
    dump if tracing?

    @size.times do |i|
      np = @new_pos[i]
      move(np, @numbers[i])
    end
  end

  def tracing?
    level = ENV["TRACE"].to_i # 0 from nil or ""
    if @size > 10
      level > 1
    else
      level > 0
    end
  end

  def dump
    puts @numbers.join(", ")
    puts
  end

  def move(from, delta)
    if delta == 0
      puts "#{@numbers[from]} does not move:" if tracing?
      dump if tracing?

      return
    end

    # remember to adjust new_pos of all the in-betweens!

    # front[] object back[]

    # delta < 0
    # front1[] object front2[] back[]

    # delta > 0
    # front[] back1[] object back2[]

    front = @numbers[0 ... from]
    object = @numbers[from]
    back = @numbers[from + 1 .. @size]

    dist = delta.abs

    if delta < 0
      front1, front2 = front[0 ... from - dist], front[from .. -1]
      back1, back2 = [], back

      left = front1.last
      right = front2.first
    else # > 0
      front1, front2 = front, []
      back1, back2 = back[0 ... dist], back[dist .. -1]

      left = back1.last
      right = back2.first
    end
    puts "Before #{front1.inspect} #{front2.inspect} #{[object].inspect} #{back1.inspect} #{back2.inspect}" if tracing?

    puts "#{object} moves between #{left} and #{right}" if tracing?
    dump if tracing?
  end

  def find_past(mark)
    -1
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  numbers = text.lines.map(&:to_i)
  mixer = Mixer.new(numbers)
  mixer.mix
  coords = [1000, 2000, 3000].map { |a| mixer.find_past(0) }
  p coords
  puts "Coordinates #{coords.sum}"
end
