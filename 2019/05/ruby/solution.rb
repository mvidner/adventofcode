#!/usr/bin/env ruby

require "stringio"

# Intcode virtual machine
class Intcode
  # @return [Array<Integer>] memory
  attr_accessor :m
  # @return [IO]
  attr_reader :stdin
  # @return [IO]
  attr_reader :stdout

  def initialize(mem, stdin = $stdin, stdout = $stdout)
    @m = mem
    @stdin = stdin
    @stdout = stdout
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
        write(0, Integer(@stdin.readline.chomp))
      # OUTPUT
      when 4
        nargs = 1
        @stdout.puts(read(0))
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

if $0 == __FILE__
  puts "Part 1"
  ic = Intcode.new(Intcode.read_file("input.txt"), StringIO.new("1", "r"))
  ic.compute
end
