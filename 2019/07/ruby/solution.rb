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
  # @return [String] for debugging
  attr_reader :name

  def initialize(mem, inq, outq, name: "Intcode")
    @m = mem
    @inq = inq
    @outq = outq
    @name = name
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
        # puts "#{name}: INqsize #{inq.size}"
        val = inq.pop
        write(0, val)
        # puts "#{name}: IN #{val}"
      # OUTPUT
      when 4
        nargs = 1
        val = read(0)
        # puts "#{name}: OUTqsize #{outq.size}"
        outq.push(val)
        # puts "#{name}: OUT #{val}"
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
    @phases.each_with_index do |ph, i|
      inq = Queue.new
      inq.push(ph)
      inq.push(input)
      outq = Queue.new
      ic = Intcode.new(@progmem.dup, inq, outq, name: "AMP#{i}(p#{ph})")
      ic.compute
      input = outq.pop
    end

    input
  end

  def run_parallel(input)
    n = @phases.size
    queues = @phases.map do |ph|
      q = Queue.new
      q.push(ph)
      # puts "#{q} size #{q.size}"
      q
    end

    amps = (0...n).map do |i|
      inq = queues[i % n]
      outq = queues[(i + 1) % n]
      # puts "#{inq.inspect} > Amp#{i} > #{outq.inspect}"
      Intcode.new(@progmem.dup, inq, outq, name: "Amp#{i}")
    end

    threads = amps.map do |amp|
      t = Thread.new do
        # sleep(rand)
        amp.compute
      end
      t.name = amp.name
      t
    end

    queues.first.push(input)
    threads.each(&:join)
    # queues.each { |q| puts "#{q} #{q.size} #{q.num_waiting}" }

    # Only after they all ran, otherwise we steal the last amp's phase setting
    # The LAST Amp outputs to the FIRST queue!
    result = queues.first.pop
    result
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

  def self.find_max_feedback_amp(progmem)
    max_amp = -1
    max_phase = nil
    (5..9).to_a.permutation do |phase|
      # puts "Trying phases #{phase.inspect}"
      ic = new(progmem, phase)
      amp = ic.run_parallel(0)

      if amp > max_amp
        max_phase = phase
        max_amp = amp
      end
    end
    puts "Max feedback amp #{max_amp} for phase #{max_phase}"
    max_amp
  end
end

if $PROGRAM_NAME == __FILE__
  progmem = Intcode.read_file("input.txt")
  puts "Part 1"
  puts AmplifierCircuit.find_max_amp(progmem)

  puts "Part 2"
  puts AmplifierCircuit.find_max_feedback_amp(progmem)
end
