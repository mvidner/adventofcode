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
    "..#",
    "..#",
    "###"
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

TILES = tiles.map { |rows| Tile.new(rows) }

class Tile
  def initialize(rows)
  end
end

class Tetris
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  moves = text.chomp.chars

  tetris = Tetris.new(moves)
end
