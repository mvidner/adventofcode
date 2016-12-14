#!/usr/bin/env ruby
require "set"

FLOORS = 4
FLOORS_1 = FLOORS - 1

# ELEMENTS = 2
ELEMENTS = 5
ELEMENTS_1 = ELEMENTS - 1

THINGS = ELEMENTS * 2
THINGS_1 = THINGS - 1
ELEMENT_NAMES = ["H", "L"].freeze

GENERATOR_NAMES = ELEMENT_NAMES.map { |e| "#{e}G" }.freeze
MICROCHIP_NAMES = ELEMENT_NAMES.map { |e| "#{e}M" }.freeze

# The state tracks the floor numbers of the elevator,
# of the generators, and of the microchips.
# Generators have even indices (starting at 0),
# microchips have the index of their generators + 1.
# The floor numbers are encoded as the distance from the top floor
# so that the goal state has all zeroes.
State = Struct.new(:elevator, :things) do
  def goal?
    elevator.zero? && things.all?(&:zero?)
  end

  def dump(io = $stdout)
    0.upto(FLOORS_1).map do |f|
      s = "F#{FLOORS - f} "
      s << (elevator  == f ? "E  " : ".  ")
      s << (things[0] == f ? "HG " : ".  ")
      s << (things[1] == f ? "HM " : ".  ")
      s << (things[2] == f ? "LG " : ".  ")
      s << (things[3] == f ? "LM " : ".  ")
      io.puts s
    end
    io.puts
  end

  # assume that the current state is valid; raise if not
  def transitions
    # indices of things
    things_at_floor = 0.upto(THINGS_1).find_all {|i| things[i] == elevator}
    raise "Invalid state: elevator at empty floor" if things_at_floor.empty?

    cargos = small_subsets(things_at_floor)

    new_elevators = []
    new_elevators << (elevator - 1) unless elevator == 0
    new_elevators << (elevator + 1) unless elevator == FLOORS - 1

    new_states = []
    new_elevators.each do |ne|
      cargos.each do |c|
        new_things = things.dup
        c.each do |i|           # i is an index of a thing
          new_things[i] = ne
        end
        new_states << State.new(ne, new_things)
      end
    end
    # some of new_states may be invalid
    new_states.find_all(&:no_chips_fried?)
  end

  # This only checks the generator-chip part of a valid state.
  # We do not check the elevator position
  def no_chips_fried?
    # For each thing we convert its floor number to a bitmap
    # (with only one bit set), and we group them to pairs of matching
    # generator+microchip.
    thing_bitmap_pairs = things.map { |floor| 1 << floor }.each_slice(2)

    # Then it is easy to get a bitmap of radioactive floors:
    radioactive_floors = thing_bitmap_pairs.reduce(0) do |acc, pair|
      acc |= pair.first         # first == generator
    end

    # And a bitmap of chips that are missing their generators
    unprotected_chips = thing_bitmap_pairs.reduce(0) do |acc, pair|
      acc |= ((~pair.first) & pair.last)
    end

    # If these bitmaps intersect, there are some fried chips
    (radioactive_floors & unprotected_chips) == 0
  end
end

# Given a set of all things at a floor, enumerate the possible contents
# the elevator could carry.
# @param set
# @return [Array] array of all subsets sized 1 or 2
def small_subsets(set)
  result = []
  arr = set.to_a
  n_1 = arr.size - 1
  0.upto(n_1).map do |row|
    result << [arr[row]]        # a singleton
    (row + 1).upto(n_1).map do |col|
      result << [arr[row], arr[col]] # a pair
    end
  end
  result
end

def transitions_from_list(states)
#  states.map(&:transitions).reduce([], &:concat)
  states.map(&:transitions).reduce(Set.new, &:merge)
end

def time_it
  t0 = Time.now
  yield
  t1 = Time.now
  printf("It took %.4g seconds.\n", t1 - t0)
end

puts "The initial state:"
# s0 = State.new(3, [2, 3, 1, 3])
s0 = State.new(3, [3, 3, 3, 3, 2, 1, 2, 2, 2, 2])
s0.dump

states = [s0]

i = 0
loop do
  i += 1
  states = transitions_from_list(states)
#  states.map(&:dump)

  puts "After #{i} steps: #{states.size} states"
  break if states.any?(&:goal?)
end
