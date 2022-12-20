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
      puts "Time #{i}, what was at #{i} is now at #{np}"
      move(np, @numbers[np])
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

    to = from + delta
    puts "UNADJ #{from} + #{delta} -> #{to}"
    # print "at #{from} by #{delta} "
    to = to % @size
    puts "A TO  #{from} + #{delta} -> #{to}"
    delta2 = delta % @size
    to2 = from + delta
    puts "A DE  #{from} + #{delta2} -> #{to2} (#{to2 % @size})"


    raise if to < 0
    delta = to - from
    puts "adjusted to #{delta}"

    dist = delta.abs
    delta1 = delta / dist # -1 or +1
    puts "D1 #{delta1}"
    dist.times do
      swap(from, from + delta1)
      from += delta1
    end

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
    puts "SWAP #{i} #{j}"
    array_swap(@numbers, i, j)

    npi, npj = @new_pos[i], @new_pos[j]
    opi, opj = @old_pos[i], @old_pos[j]

    @new_pos[opj] = i
    @new_pos[opi] = j
    @old_pos[npj] = i
    @old_pos[npi] = j
    print "    "
    dump
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
