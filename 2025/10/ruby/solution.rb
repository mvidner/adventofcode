#!/usr/bin/env ruby
require "set"

class Machine
  # Target state.
  #
  # We represent them as bits in an integer
  # with the least significant bit representing
  # the light number 0, printed at the left:
  # [...##.] is 24
  # @return [Integer]
  attr_reader :lights_bits

  # @return [Array<Integer>] buttons as light bitmasks
  attr_reader :buttons_bits

  # @return [Array<Array<Integer>>] buttons as tuples of light indices
  attr_reader :buttons

  # @return [Array<Integer>] target state
  attr_reader :joltages

  def self.parse(line)
    line =~ /\[([.#]+)\]/
    lights_s = Regexp.last_match(1)
    lights_bits = lights_s.reverse.tr(".#", "01").to_i(2)

    # longest string starting and ending with round brackets
    line =~ /(\(.*\))/
    buttons_s = Regexp.last_match(1)
    buttons = buttons_s.split(" ").map do |button_s|
      button_s[1..-2].split(",").map(&:to_i)
    end

    line =~ /\{(.*)\}/
    joltages_s = Regexp.last_match(1)
    joltages = joltages_s.split(",").map(&:to_i)

    new(lights_bits, buttons, joltages)
  end

  def initialize(lights_bits, buttons, joltages)
    @lights_bits = lights_bits
    @buttons = buttons
    @joltages = joltages

    @buttons_bits = buttons.map do |numbers|
      numbers.map do |n|
        2**n
      end.sum
    end
  end

  def popcount(num)
    num.to_s(2).count("1")
  end

  # lights are bits
  def light_presses
    p self if $DEBUG
    good_presses = []
    # Key observation: each button needs AT MOST ONE press.
    # Can do a dumb exhaustive search
    (2**buttons_bits.size).times do |presses|
      puts if $DEBUG
      puts "Presses: #{presses.to_s(2)}" if $DEBUG
      state = 0
      buttons_bits.each_with_index do |b, i|
        puts "Button ##{i}, #{b.to_s(2)}" if $DEBUG
        if ((2**i) & presses) != 0
          puts " pressed" if $DEBUG
          state ^= b
        end
      end
      puts "Result: #{state.to_s(2)}" if $DEBUG
      puts "Wanted: #{lights.to_s(2)}" if $DEBUG
      next if state != lights_bits

      good_presses << presses
    end

    good_presses.map { |p| popcount(p) }.min || raise("No solution found")
  end

  # implementing the Pseudocode from https://en.wikipedia.org/wiki/Breadth-first_search
  # @param graph implementing adjacent(Vertex) -> Enumerable[Vertex]
  # @param root [Vertex]
  # @param goal_p Proc(Vertex -> Boolean)
  # @return [(Vertex or nil, Integer, Hash{Vertex => Vertex})] a triple:
  #   goal vertex, path length (number of edges), reverse path hash
  def breadth_first_search(graph, root, goal_p)
    length = 0
    reverse_path = {}

    explored = [root].to_set
    queue = []
    queue.push(root)
    queue.push(:next_layer)
    until queue.empty?
      v = queue.shift
      puts "At #{v.inspect}" if $DEBUG

      if v == :next_layer
        length += 1
        queue.push(:next_layer)
        next
      end

      return [v, length, reverse_path] if goal_p.call(v)

      graph.adjacent(v).each do |w|
        next if explored.include?(w)

        explored << w
        reverse_path[w] = v
        queue.push(w)
      end
    end

    # not found
    [nil, length, reverse_path]
  end

  # a vertex is a tuple of joltage states
  #
  # Note on vertex identity:
  # this generates copies of vertices but that's fine because
  # the `explored` Set compares equality, not identity
  def adjacent(js)
    buttons.map do |numbers|
      new_js = js.dup
      numbers.each do |i|
        new_js[i] += 1
      end
      new_js
    end
  end

  def joltage_presses
    initial = joltages.map { |_j| 0 }
    _goal, presses, _reverse_path = breadth_first_search(self, initial, ->(v) { v == joltages })
    presses
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  ms = text.lines.map do |line|
    Machine.parse(line)
  end
  puts "Machine count: #{ms.size}"

  presses = ms.map(&:light_presses).sum
  puts "Fewest button presses: #{presses}"

  presses = ms.map(&:joltage_presses).sum
  puts "Fewest joltage button presses: #{presses}"
end
