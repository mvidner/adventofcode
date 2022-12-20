#!/usr/bin/env ruby

class Mixer
  def initialize(numbers)
    @numbers = numbers.dup # things
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
      puts if tracing?

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
  end

  # *from* is within bounds
  def move(from, delta)
    raise ArgumentError unless (0...@size).include?(from)

    if delta == 0
      puts "#{@numbers[from]} does not move:" if tracing?
      dump if tracing?
      return
    end

    puts "#{@numbers[from]} moves ...:" if tracing?
    want_to = nil
    loop do
      want_to = from + delta
      # break if (0...@size).include?(want_to)
      # but NO, it cannot end at position zero, W T F ! ! 1 !
      break if want_to > 0 && want_to < @size

      if want_to.abs > 2 * @size
        delta = delta % (@size - 1)
        # puts "new delta #{delta}"
      end

      # div, mod = delta.divmod(@size)
      # p [div, mod]
      # print "   "
      # p delta.divmod(@size - 1)

      if delta < 0
        delta += @size - 1
      else
        delta -= @size - 1
      end
      puts "WRAPPED, new delta #{delta}" if tracing?
    end
    to = want_to
    delta = to - from

    dist = delta.abs
    delta1 = delta / dist # -1 or +1
    # puts "D1 #{delta1}"
    dist.times do
      swap(from, from + delta1)
      from += delta1
    end
    dump if tracing?
  end

  def array_swap(arr, i, j)
    tmp = arr[i]
    arr[i] = arr[j]
    arr[j] = tmp
  end

  def swap(i, j)
    # puts "SWAP #{i} #{j}"
    # print "    "; dump

    array_swap(@numbers, i, j)

    opi, opj = @old_pos[i], @old_pos[j]
    @new_pos[opj] = i
    @new_pos[opi] = j

    @old_pos[i] = opj
    @old_pos[j] = opi

    # puts "    OLD: #{@old_pos.inspect}"
    # puts "    NEW: #{@new_pos.inspect}"
    # print "    "; dump
  end


  def find_past(mark, offset)
    i = @numbers.index(mark)
    raise "Mark #{mark} not found" if i.nil?
    @numbers[(i + offset) % @size]
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  numbers = text.lines.map(&:to_i)
  mixer = Mixer.new(numbers)
  mixer.mix
  coords = [1000, 2000, 3000].map { |ofs| mixer.find_past(0, ofs) }
  p coords
  puts "Coordinates #{coords.sum}"

  key = 811589153
  m2 = Mixer.new(numbers.map { |n| n * key })
  10.times do |r|
    m2.mix
    puts "After #{r+1} round of mixing"
    m2.dump
  end
  coords = [1000, 2000, 3000].map { |ofs| m2.find_past(0, ofs) }
  p coords
  puts "Coordinates #{coords.sum}"
end
