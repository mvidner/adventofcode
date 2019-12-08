#!/usr/bin/env ruby

# Intcode virtual machine
#
# The input and output are done by pushing and popping integers on
# the input and output queues
class Intcode
  # @return [Array<Integer>] memory
  attr_accessor :m
  # @return [Queue] input queue
  attr_reader :inq
  # @return [Queue] output queue
  attr_reader :outq

  def initialize(mem, inq, outq)
    @m = mem
    @inq = inq
    @outq = outq
    @ip = 0
  end

  def self.read_file(fname)
    File.read(fname).split(",").map { |s| Integer(s) }
  end

  # The memory is modified
  def compute
    loop do
      nargs = nil # force handling every case

      insn = @m[@ip]
      case insn % 100
      # ADD
      when 1
        nargs = 3
        write(2, read(0) + read(1))
      # MUL
      when 2
        nargs = 3
        write(2, read(0) * read(1))
      # INPUT
      when 3
        nargs = 1
        write(0, inq.pop)
      # OUTPUT
      when 4
        nargs = 1
        outq.push(read(0))
      # JUMP-IF-TRUE
      when 5
        nargs = 2
        if read(0) != 0
          @ip = read(1)
          nargs = -1
        end
      # JUMP-IF-FALSE
      when 6
        nargs = 2
        if read(0).zero?
          @ip = read(1)
          nargs = -1
        end
      # LESS-THAN
      when 7
        nargs = 3
        value = read(0) < read(1) ? 1 : 0
        write(2, value)
      # EQUALS
      when 8
        nargs = 3
        value = read(0) == read(1) ? 1 : 0
        write(2, value)
      when 99
        break
      else
        raise "Unexpected opcode #{@m[@ip].inspect} at position #{@ip}"
      end

      @ip += 1 + nargs
    end

    m[0]
  end

  # @param a 0-based arg number
  def read(a)
    mode = argmode(@m[@ip], a)
    case mode
    when 0                      # position
      @m[@m[@ip + 1 + a]]
    when 1                      # immmediate
      @m[@ip + 1 + a]
    else
      raise "Unexpected mode #{mode}"
    end
  end

  # @param a 0-based arg number
  def write(a, value)
    mode = argmode(@m[@ip], a)
    case mode
    when 0                      # position
      @m[@m[@ip + 1 + a]] = value
    when 1                      # immmediate
      raise "Cannot write to immediate values"
    else
      raise "Unexpected mode #{mode}"
    end
  end

  def argmode(insn, a)
    (insn / 100) / (10**a) % 10
  end
end

# A series of 5 Intcode computers
class AmplifierCircuit
  def initialize(progmem, phases)
    @progmem = progmem
    @phases = phases
  end

  def run(input)
    @phases.each do |ph|
      inq = Queue.new
      inq.push(ph)
      inq.push(input)
      outq = Queue.new
      ic = Intcode.new(@progmem.dup, inq, outq)
      ic.compute
      input = outq.pop
    end

    input
  end

  def self.find_max_amp(progmem)
    max_amp = -1
    max_phase = nil
    (0..4).to_a.permutation do |phase|
      ic = new(progmem, phase)
      amp = ic.run(0)

      if amp > max_amp
        max_phase = phase
        max_amp = amp
      end
    end
    puts "Max amp #{max_amp} for phase #{max_phase}"
    max_amp
  end
end

if $PROGRAM_NAME == __FILE__
  puts "Part 1"
  puts AmplifierCircuit.find_max_amp(Intcode.read_file("input.txt"))

  puts "Part 2"
  puts "?"
end
