#!/usr/bin/ruby

require "yaml"

class DiskUse
  def initialize(log)
    @dir_stack = []

    # key=name, value= file size or hash as dir contents
    @top_dir = {"/" => {}}
    @cur_dir = @top_dir
        
    log.split("$ ").each do |cmd|
      next if cmd == ""
      case cmd
      when /\Acd (.*)/
        cd($1)
      when /\Als/
        ls(cmd.split("\n")[1..-1])
      else
        raise "unrecognized command #{cmd.inspect}"
      end
    end

#    puts @top_dir.to_yaml
  end
  
  def cd(dir)
    if dir == ".."
      @cur_dir = @dir_stack.pop
    else
      @dir_stack.push(@cur_dir)
      @cur_dir = @cur_dir.fetch(dir)
    end
  end
    
  def ls(out_lines)
    out_lines.each do |line|
      case line
      when /^dir (.*)/
        name = $1

        @cur_dir[name] = {}
      when /^(\d+) (.*)/
        size = $1.to_i
        name = $2

        @cur_dir[name] = size
      else
        raise "unrecognized ls output #{line.inspect}"
      end
    end
  end

  def dir_size(hash, ignore_over: Float::INFINITY)
    sizes = hash.values.map do |val|
      if val.is_a?(Hash)
        dir_size(val, ignore_over: ignore_over) do |passthru|
          yield(passthru)
        end
      else
        val
      end
    end
    sizes = sizes.find_all { |sz| sz <= ignore_over }
    # puts "Hash: #{hash}"
    # puts "Sizes: #{sizes}"
    # puts "Result: #{sizes.sum}"
    total = sizes.sum
    yield(total)
    total
  end
  
  def total_small_size
    total = 0
    @used = dir_size(@top_dir["/"]) do |size|
      # puts "+#{size}"
      total += size if size <= 100_000
    end
    total
  end

  def dir_to_delete
    unused = 70_000_000 - @used
    needed = 30_000_000 - unused
    puts "(Needed #{needed})"

    smallest_enough = Float::INFINITY
    dir_size(@top_dir["/"]) do |size|
      next if size < needed
      smallest_enough = size if smallest_enough > size
    end
    smallest_enough
  end
end

du = DiskUse.new(File.read(ARGV[0] || "input.txt"))
puts "Small dir size sum: #{du.total_small_size}"

puts "Smallest dir to delete: #{du.dir_to_delete}"
