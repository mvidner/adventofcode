#!/usr/bin/env ruby

class Machine
  # Number of lights
  # @return [Integer]
  attr_reader :n_lights

  # Target state.
  #
  # We represent them as bits in an integer
  # with the least significant bit representing
  # the light number 0, printed at the left:
  # [...##.] is 24
  # @return [Integer]
  attr_reader :lights

  # @return [Array<Integer>]
  attr_reader :buttons

  def self.parse(line)
    line =~ /\[([.#]+)\]/
    lights_s = Regexp.last_match(1)
    n_lights = lights_s.length
    lights = lights_s.reverse.tr(".#", "01").to_i(2)

    # longest string starting and ending with round brackets
    line =~ /(\(.*\))/
    buttons_s = Regexp.last_match(1)
    buttons = buttons_s.split(" ").map do |button_s|
      numbers = button_s[1..-2].split(",").map(&:to_i)
      numbers.map do |n|
        2**n
      end.sum
    end

    # joltages: not needed for the first star

    new(n_lights, lights, buttons)
  end

  def initialize(n_lights, lights, buttons)
    @n_lights = n_lights
    @lights = lights
    @buttons = buttons
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
    (2**buttons.size).times do |presses|
      puts if $DEBUG
      puts "Presses: #{presses.to_s(2)}" if $DEBUG
      state = 0
      buttons.each_with_index do |b, i|
        puts "Button ##{i}, #{b.to_s(2)}" if $DEBUG
        if ((2**i) & presses) != 0
          puts " pressed" if $DEBUG
          state ^= b
        end
      end
      puts "Result: #{state.to_s(2)}" if $DEBUG
      puts "Wanted: #{lights.to_s(2)}" if $DEBUG
      next if state != lights

      good_presses << presses
    end

    good_presses.map { |p| popcount(p) }.min || raise("No solution found")
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  ms = text.lines.map do |line|
    Machine.parse(line)
  end

  presses = ms.map(&:light_presses).sum
  puts "Fewest button presses: #{presses}"
end
