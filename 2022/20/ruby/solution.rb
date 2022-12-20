#!/usr/bin/env ruby

class Mixer
  def initialize(numbers)
    @numbers = numbers # things
    @size = @numbers.size

    # new_pos[a] == b means that
    # the thing that was at *a* at the start is now at *b*
    @new_pos = (0 ... @size).to_a
    # thing that is now at *a* was at old_pos[a] at the start
    @old_pos = (0 ... @size).to_a
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

    print "at #{from} by #{delta} "
    to = (from + delta) % @size
    raise if to < 0
    delta = to - from
    puts "adjusted to #{delta}"
    # remember to adjust new_pos of all the in-betweens!

    # front[] thing back[]

    # delta < 0
    # front1[] thing front2[] back[]

    # delta > 0
    # front[] back1[] thing back2[]

    front = @numbers[0 ... from]
    thing = @numbers[from]
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
    puts "Before #{front1.inspect} #{front2.inspect} #{thing} #{back1.inspect} #{back2.inspect}" if tracing?
    puts "#{thing} moves between #{left} and #{right}" if tracing?

    if delta < 0
      save_numbers = @numbers[to]
      @numbers[to] = @numbers[from]

      save_old = @old_pos[to]
      @old_pos[to] = @old_pos[from]
      save_new
      @new_pos[]
    else
    end
    @new_pos[from] = to

    puts "OLD: #{@old_pos.inspect}"
    puts "NEW: #{@new_pos.inspect}"
    dump if tracing?
  end

  # move a thing from *from* one position to the right
  def move_right(from)
    to = (from + 1) % size
    swap(from, to)
  end

  def array_swap(arr, i, j)
    tmp = arr[i]
    arr[i] = arr[j]
    arr[j] = tmp
  end

  def swap(i, j)
    array_swap(@numbers, i, j)

    npi, npj = @new_pos[i], @new_pos[j]
    opi, opj = @old_pos[i], @old_pos[j]

    @new_pos[opj] = i
    @new_pos[opi] = j
    @old_pos[npj] = i
    @old_pos[npi] = j
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
