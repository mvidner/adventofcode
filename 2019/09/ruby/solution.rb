#!/usr/bin/env ruby

# Intcode virtual machine
#
# The input and output are done by pushing and popping integers on
# the input and output queues
class Intcode
  # Array of Integers that grows automatically.
  class Memory
    # The object mutates its initializing argument
    def initialize(array)
      @array = array
    end

    def [](i)
      raise "Negative index #{i} not allowed" if i < 0
      # Uninitialized cells are 0
      @array[i] || 0
    end

    def []=(i, v)
      raise "Negative index #{i} not allowed" if i < 0
      @array[i] = v
    end

#    def to_a
#      @array
#    end
  end

  # @return [Memory] memory
  attr_accessor :mem
  # @return [Queue] input queue
  attr_reader :inq
  # @return [Queue] output queue
  attr_reader :outq
  # @return [String] for debugging
  attr_reader :name

  def initialize(mem, inq, outq, name: "Intcode")
    @mem = mem
    @inq = inq
    @outq = outq
    @name = name
    @ip = 0                     # instruction pointer
    @rbase = 0                  # relative base for arg mode 2
  end

  def self.read_file(fname)
    File.read(fname).split(",").map { |s| Integer(s) }
  end

  # The memory is modified
  def compute
    loop do
      nargs = nil # force handling every case

      insn = mem[@ip]
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
      # ADJRBASE
      when 9
        nargs = 1
        @rbase += read(0)
      when 99
        break
      else
        raise "Unexpected opcode #{mem[@ip].inspect} at position #{@ip}"
      end

      @ip += 1 + nargs
    end

    mem[0]
  end

  # @param a 0-based arg number
  def read(a)
    mode = argmode(mem[@ip], a)
    arg = mem[@ip + 1 + a]
    case mode
    when 0                      # position
      mem[arg]
    when 1                      # immediate
      arg
    when 2
      mem[@rbase + arg]
    else
      raise "Unexpected mode #{mode}"
    end
  end

  # @param a 0-based arg number
  def write(a, value)
    mode = argmode(mem[@ip], a)
    arg = mem[@ip + 1 + a]
    case mode
    when 0                      # position
      mem[arg] = value
    when 1                      # immediate
      raise "Cannot write to immediate values"
    when 2
      mem[@rbase + arg] = value
    else
      raise "Unexpected mode #{mode}"
    end
  end

  def argmode(insn, a)
    (insn / 100) / (10**a) % 10
  end
end

if $PROGRAM_NAME == __FILE__
  progmem = Intcode.read_file("input.txt")
  puts "Part 1"
  inq = Queue.new
  outq = Queue.new
  ic = Intcode.new(progmem.dup, inq, outq)
  inq.push(1)
  ic.compute
  puts outq.pop

  puts "Part 2"
  inq = Queue.new
  outq = Queue.new
  ic = Intcode.new(progmem.dup, inq, outq)
  inq.push(2)
  ic.compute
  puts outq.pop
end
