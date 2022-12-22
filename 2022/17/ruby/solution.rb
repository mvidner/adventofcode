#!/usr/bin/env ruby
require "set"

Pos = Struct.new(:r, :c) do
  def +(pair)
    Pos.new(r + pair[0], c + pair[1])
  end
end

tiles = [
  [
    "####"
  ],
  [
    ".#.",
    "###",
    ".#."
  ],
  [
    # bottom line has index 0
    "###",
    "..#",
    "..#"
  ],
  [
    "#",
    "#",
    "#",
    "#"
  ],
  [
    "##",
    "##"
  ],
]

class Tile
  def initialize(rows)
    @rows = rows
  end

  attr_reader :rows
end

TILES = tiles.map { |rows| Tile.new(rows) }

class Tetris
  def initialize(moves)
    @moves = moves
    @next_move = 0

    @width = 7
    @height = 0
    @next_tile = 0

    # row 0 is bottom
    @rows = []
  end

  # distance of topmost rock from the floor
  attr_reader :height

  def dump
    (@height - 1).downto(0) do |ri|
      puts "|#{@rows[ri]}| #{ri}"
    end
    puts "+#{"-" * @width}+"
  end

  # Drop one tile until it lands
  # using *moves* on it as it falls
  def drop
    tile = TILES[@next_tile]
    @next_tile = (@next_tile + 1) % TILES.size

    spawn(tile)

  end

  def make_rows(count)
    Array.new(count) { "." * @width }
  end

  LEFT_PAD = 2
  BOTTOM_PAD = 3

  def spawn(tile)
    @rows.concat(make_rows(BOTTOM_PAD))
    @height += BOTTOM_PAD

    tile_height = tile.rows.size
    fresh_rows = make_rows(tile_height)
    fresh_rows.zip(tile.rows).each do |fr, tr|
      fr[2, tr.size] = tr
    end
    @rows.concat(fresh_rows)
    @height += tile_height
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  moves = text.chomp.chars

  tetris = Tetris.new(moves)
  puts "Initially"
  tetris.dump
  2022.times do |i|
    tetris.drop
    tetris.dump
  end
  puts "Finally"
  tetris.dump
  puts "Height: #{tetris.height}"

end
