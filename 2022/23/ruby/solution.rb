#!/usr/bin/env ruby
require "set"

# XY or Row Col? Here the coords ar unbounded, and can get negative
Pos = Struct.new(:x, :y) do
  def inspect
    "[#{x} #{y}]"
  end

  def +(other)
    Pos[x + other.x, y + other.y]
  end
end

DIRECTIONS = [:N, :S, :W, :E]

DELTAS = {
  N: Pos[0, 1],
  S: Pos[0, -1],
  W: Pos[-1, 0],
  E: Pos[1, 0]
}

ALL_NEIGHBORS = [
  Pos[-1, 1],  Pos[0, 1],  Pos[1, 1],
  Pos[-1, 0],              Pos[1, 0],
  Pos[-1, -1], Pos[0, -1], Pos[1, -1]
]

LOOK = {
  N: [Pos[0, 1],  Pos[1, 1],  Pos[-1, 1],  ],
  S: [Pos[0, -1], Pos[1, -1], Pos[-1, -1], ],
  W: [Pos[-1, 0], Pos[-1, 1], Pos[-1, -1], ],
  E: [Pos[1, 0],  Pos[1, 1],  Pos[1, -1],  ],
}

class Diffusion
  def initialize(text)
    @first_direction = 0
    @elves = [].to_set

    text.lines.each_with_index do |l, y|
      l.chars.each_with_index do |c, x|
        @elves << Pos[x, -y] if c == "#"
      end
    end
  end

  # @return pair min_pos, max_pos
  def bounding_box
    minx, maxx = @elves.map { |e| e.x }.minmax
    miny, maxy = @elves.map { |e| e.y }.minmax
    [Pos[minx, miny], Pos[maxx, maxy]]
  end

  def dump
    min, max = bounding_box
    max.y.downto(min.y) do |y|
      min.x.upto(max.x) do |x|
        c = @elves.include?(Pos[x, y]) ? "#" : "."
        print c
      end
      puts
    end
  end

  def next_direction
    @first_direction = (@first_direction + 1) % DIRECTIONS.size
  end

  def round
    # *want* is a Hash{Pos => Array<Pos>}
    # key: destination position
    # values: source positions that want to get there
    want = propose
    still_going = commit(want)
    next_direction

    still_going
  end

  def round_directions
    ret = (DIRECTIONS + DIRECTIONS)[@first_direction ... @first_direction + 4]
    p ret
    ret
  end

  def count_neighbors(pos, candidate_deltas)
    candidate_deltas.reduce(0) do |sum, delta|
      sum + (@elves.include?(pos + delta) ? 1 : 0)
    end
  end

  def propose
    want = {}
    @elves.each do |e|
      ns = count_neighbors(e, ALL_NEIGHBORS)
      if ns == 0
        dest = e # unchanged
      else
        found_dir = round_directions.find do |dir|
          dns = count_neighbors(e, LOOK[dir])
          dns == 0
        end
        # raise "Elf #{e} has nowhere to move" if found_dir.nil?

        if found_dir
          dest = e + DELTAS[found_dir]
        else
          dest = e
        end
      end

      want[dest] ||= []
      want[dest] << e
    end
    pp want
  end

  # @return [Boolean] anyone moved? then we should go on
  def commit(want)
    anyone_moved = false
    new_elves = [].to_set

    want.each do |dest, sources|
      if sources.size > 1
        new_elves.merge(sources)
      else
        anyone_moved = true
        new_elves.add(dest)
      end
    end

    @elves = new_elves
    anyone_moved
  end

  def count_empty
    min, max = bounding_box
    area = (max.x - min.x + 1) * (max.y - min.y + 1)
    area - @elves.size
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")

  d = Diffusion.new(text)
  10.times do |i|
    puts "Round #{i+1}"
    d.round
  end
  puts "Empty positions: #{d.count_empty}"
end
