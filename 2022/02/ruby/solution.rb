#!/usr/bin/env ruby

text = File.read(ARGV[0] || "input.txt")
# list of pairs
data = text.split("\n").map { |line| line.split }
#puts data.size

RPS_WIN = {
  "R" => {"R" => 0, "P" => -1, "S" => 1},
  "P" => {"R" => 1, "P" => 0, "S" => -1},
  "S" => {"R" => -1, "P" => 1, "S" => 0},
}

# -1 I lose, 0 draw, 1 I win
def i_win(mine, other)
  RPS_WIN[mine][other]
end

def my_points(mine, other)
  (i_win(mine, other) + 1) * 3  
end

def round_score(abc, xyz)
  other = { "A" => "R", "B" => "P", "C" => "S" }[abc]
  mine = { "X" => "R", "Y" => "P", "Z" => "S" }[xyz]
  bonus = { "R" => 1, "P" => 2, "S" => 3 }

  my_points(mine, other) + bonus[mine]
end

def round_score_official(abc, xyz)
  other = { "A" => "R", "B" => "P", "C" => "S" }[abc]
  # X Y Z is Lose Draw Win
  wanted = { "X" => -1, "Y" => 0, "Z" => 1 }[xyz]
  mine = ["R", "P", "S"].find do |m|
    i_win(m, other) == wanted
  end

  bonus = { "R" => 1, "P" => 2, "S" => 3 }

  my_points(mine, other) + bonus[mine]
end

total_score = data.map { |round| round_score(round[0], round[1]) }.sum
puts "Total score: #{total_score}"
official_total_score = data.map { |round| round_score_official(round[0], round[1]) }.sum
puts "Official Total score: #{official_total_score}"
