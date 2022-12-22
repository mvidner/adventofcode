#!/usr/bin/env ruby

# Coords: row (growing down), col

class Step
  # Specified direction numbers: 0 right, 1 down, 2 left, 3 up
  DELTA = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ]

  FACES = [">", "v", "<", "^"]

  # exactly one of :angle, distance is not zero

  # +1 to the right/clockwise
  # -1 left, ccw
  attr_reader :angle
  # @return [Integer]
  attr_reader :distance
  def initialize(angle, distance)
    raise if angle == 0 && distance == 0
    @angle = angle
    @distance = distance
  end

  # @return [Array<Step>]
  def self.parse(text)
    i = 0
    result = []
    loop do
      case text[i..-1]
      when ""
        break
      when /^(\d+)/
        distance = $1.to_i
        result << Step.new(0, distance)
        i += $1.size
      when /^L/
        result << Step.new(-1, 0)
        i += 1
      when /^R/
        result << Step.new(1, 0)
        i += 1
      else
        raise text[i, 5].inspect
      end
    end
    result
  end
end

# Tiles:
# Open '.' (or ^v<> if we've been here);
#   detect only Void and Wall to avoid being confused by trail marks
# Wall '#'
# Void ' '
class Map
  def initialize(text, pass_thru_walls: false)
    @pass_thru_walls = pass_thru_walls
    @rows = text.lines.map(&:chomp)

    # but they are ragged at the right! rectangularize!
    width = @rows.map(&:size).max
    @rows.each do |r|
      newr = r + (" " * (width - r.size))
      r.replace(newr)
    end

    @dir = 0 # right
    @pos = [0, @rows[0].index(".")]
    snail_mark
  end

  def snail_mark
    @rows[@pos[0]][@pos[1]] = Step::FACES[@dir]
  end

  def dump
    cols = @rows[0].size.times.map { |c| format("%3d", c) }
    col_labels = lambda do
      cols[0].size.times.map do |i|
        digits = cols.map { |s| s[i] }.join
        puts digits unless digits.strip.empty?
      end
    end

    col_labels.call
    @rows.each_with_index do |r, i|
      puts "#{r}| #{i}"
    end
    col_labels.call
  end

  def go(steps)
    steps.each do |step|
      go1(step)
    end
    # puts "Final #{[@dir, @pos].inspect}"
  end

  def go1(step)
    if $sus
      puts
      puts "At #{[@dir, @pos].inspect}"
      puts "Go1 #{step.inspect}"
    end

    if step.distance == 0
      @dir = (@dir + step.angle) % Step::DELTA.size
      snail_mark
      return
      # that was easy
    end

    step.distance.times do
      ndir, npos = wrap_step(@pos[0], @pos[1], @dir)
      nrow, ncol = npos
      return if !@pass_thru_walls && @rows[nrow][ncol] == "#"

      @dir = ndir
      @pos = nrow, ncol
      snail_mark
    end
  end

  # Do a single step, wrapping around the edges and skipping the Void
  # @param dir [0,1,2,3] as in Step, FIXME: not a nice dependency?
  # return [dir, [row, col]] with Open or Wall, not Void
  def wrap_step(row, col, dir)
    drow, dcol = Step::DELTA[dir]
    puts "WS #{row}, #{col}, #{drow}, #{dcol}" if $sus

    loop do
      row = (row + drow) % @rows.size
      col = (col + dcol) % @rows[row].size
      # stepped, possibly wrapped
      tile = @rows[row][col]
      break unless tile == " "
    end

    [dir, [row, col]]
  end

  def password
    1000 * (@pos[0] + 1) + 4 * (@pos[1] + 1 ) + @dir
  end
end

Transition = Struct.new(:new_ro, :new_co, :dir_change) do
  # dir_change is +1 for CW (clockwise), -1 CCW (counterclockwise),
  #   0 none, 2 U-turn;
  #   and these match with Step::DELTA and FACES

  # ro and co are row offset, column offset, within their face, that is
  # 0 <= ro, co < esize (edge size)

  # The values of new_ro, new_co are symbols, meaning
  # :ro, :co - just copy the old row or column offset
  # :iro, :ico - inverted offset:
  #   input ranges from 0 to esize-1, output goes inversely from esize-1 to 0;
  #   In some special cases input is only 0 or esize-1 which originally
  #   lead me to introducew :wro, :wco with wrapping
end

# typing shortcut
class T
  def self.[](r, c, d)
    Transition.new(r, c, d)
  end
end

BigTransition = Struct.new(:face_row_delta, :face_col_delta, :transition)

class B
  def self.[](face_row_delta, face_col_delta, transition)
    BigTransition.new(face_row_delta, face_col_delta, transition)
  end
end

class TransitionEvaluator
  def initialize(ro, co, esize)
    @ro = ro
    @co = co
    @esize = esize
  end

  attr_reader :ro, :co

  def iro
    (@esize - 1) - ro
  end

  def ico
    (@esize - 1) - co
  end

  def eval(transition)
    r_method, c_method, _rot = transition.to_a

    nro = self.public_send(r_method)
    nco = self.public_send(c_method)

    [nro, nco]
  end
end

class CubeMap < Map
  JOIN_LR = T[:ro, :ico, 0]
  JOIN_UD = T[:iro, :co, 0]

  # quadrants:
  #
  # Q1 | Q0
  # ---+---
  # Q2 | Q3
  ROT_Q0_CW = ROT_Q2_CW = T[:ico, :iro, 1]
  ROT_Q0_CCW = ROT_Q2_CCW = T[:ico, :iro, -1]
  ROT_Q1_CW = ROT_Q3_CW = T[:co, :ro, 1]
  ROT_Q1_CCW = ROT_Q3_CCW = T[:co, :ro, -1]

  UTURN_LR = T[:iro, :co, 2]
  UTURN_UD = T[:ro, :ico, 2]

  # A FaceTransition is a quadruple of 4 BigTransitions (naming sucks iknow)
  #
  # A BigTransition is a
  # Transitions,
  # arranged as a hash keyed :u :l :d :r for up left down right.
  # NOFACE means no transitions should occur there.
  NOFACE = {}

  # TRANSITIONS_* is indexed by rows and columns of faces,
  # as they appear in the input

  # sample.txt has faces laid out like
  # ..X.
  # XXX.
  # ..XX
  # So '.' will have NOFACE and X will have a FaceTransition
  TRANSITIONS_SAMPLE = [
    [
      NOFACE,
      NOFACE,
      # [0, 2]
      {
        u: B[1, -2, UTURN_UD],
        l: B[1, -1, ROT_Q1_CCW],
        d: B[1, 0, JOIN_UD],
        r: B[2, 1, UTURN_LR]
      },
      NOFACE
    ],
    [
      # [1, 0]
      {
        u: B[-1, 2, UTURN_UD],
        l: B[1, 3, ROT_Q0_CW],
        d: B[1, 2, UTURN_UD],
        r: B[0, 1, JOIN_LR]
      },
      # [1, 1]
      { u: B[-1, 1, ROT_Q1_CW],
        l: B[0, -1, JOIN_LR],
        d: B[1, 1, ROT_Q2_CCW],
        r: B[0, 1, JOIN_LR]
      },
      # [1, 2]
      {
        u: B[-1, 0, JOIN_UD],
        l: B[0, -1, JOIN_LR],
        d: B[1, 0, JOIN_UD],
        r: B[1, 1, ROT_Q0_CW]
      },
      NOFACE
    ],
    [
      NOFACE,
      NOFACE,
      # [2, 2]
      {
        u: B[-1, 0, JOIN_UD],
        l: B[-1, -1, ROT_Q2_CW],
        d: B[-1, -2, UTURN_UD],
        r: B[0, 1, JOIN_LR]
      },
      # [2, 3]
      { u: B[-1, -1, ROT_Q0_CCW],
        l: B[0, -1, JOIN_LR],
        d: B[-1, -3, ROT_Q0_CCW],
        r: B[-2, -1, UTURN_LR]
      }
    ]
  ]

  TRANSITIONS_INPUT = [
    [
      NOFACE,
      # [0, 1]
      {
        u: B[3, -1, ROT_Q3_CW],
        l: B[2, -1, UTURN_LR],
        d: B[1, 0, JOIN_UD],
        r: B[0, 1, JOIN_LR]
      },
      # [0, 2]
      {
        u: B[3, -2, JOIN_UD], # bug: was UTURN_UD
        l: B[0, -1, JOIN_LR],
        d: B[1, -1, ROT_Q3_CW],
        r: B[2, -1, UTURN_LR]
      }
    ],
    [
      NOFACE,
      # [1, 1]
      {
        u: B[-1, 0, JOIN_UD],
        l: B[1, -1, ROT_Q1_CCW],
        d: B[1, 0, JOIN_UD],
        r: B[-1, 1, ROT_Q3_CCW]
      },
      NOFACE
    ],
    [
      # [2, 0]
      {
        u: B[-1, 1, ROT_Q1_CW],
        l: B[-2, 1, UTURN_LR],
        d: B[1, 0, JOIN_UD],
        r: B[0, 1, JOIN_LR]
      },
      # [2, 1]
      {
        u: B[-1, 0, JOIN_UD],
        l: B[0, -1, JOIN_LR],
        d: B[1, -1, ROT_Q3_CW],
        r: B[-2, 1, UTURN_LR]
      },
      NOFACE
    ],
    [
      # [3, 0]
      {
        u: B[-1, 0, JOIN_UD],
        l: B[-3, 1, ROT_Q3_CCW],
        d: B[-3, 2, JOIN_UD], # 20 minutes, later, the reverse direction of the bug
        r: B[-1, 1, ROT_Q3_CCW]
      },
      NOFACE,
      NOFACE
    ]
  ]

  # Do a single step, wrapping around cube edges
  # @param dir [0,1,2,3] as in Step, FIXME: not a nice dependency?
  # return [dir, [row, col]] with Open or Wall, not Void
  def wrap_step(row, col, dir)
    drow, dcol = Step::DELTA[dir]
    puts "WS #{row}, #{col}, #{drow}, #{dcol}" if $sus

    # row face, col face
    # row offset, col offset
    rowf, rowo = row.divmod(esize)
    colf, colo = col.divmod(esize)

    # where we'd go in the planar map...
    nrow = row + drow
    ncol = col + dcol
    # ... and what face it would mean
    nrowf = nrow / esize
    ncolf = ncol / esize

    # simple case: staying on the same face
    return [@dir, [nrow, ncol]] if nrowf == rowf && ncolf == colf

    # now nrow nrowf are invalid
    puts "cube wrap #{[row, col]} -> #{[nrow, ncol]} from face #{[rowf, colf]} dir #{Step::FACES[dir]}"

    transitions = case esize
                  when 50
                    TRANSITIONS_INPUT
                  when 4
                    TRANSITIONS_SAMPLE
                  else
                    raise "Now you have to hardcode another cube, good luck"
                  end
    face_transition = transitions[rowf][colf]
    raise "Bug: no transition defined here" if face_transition == NOFACE

    ft_idx = [:r, :d, :l, :u][dir]
    big_transition = face_transition[ft_idx]

    nrowf = rowf + big_transition.face_row_delta
    ncolf = colf + big_transition.face_col_delta

    transition = big_transition.transition
    te = TransitionEvaluator.new(rowo, colo, esize)
    nrowo, ncolo = te.eval(transition)

    ndir = (dir + transition.dir_change) % 4
    nrow = nrowf * esize + nrowo
    ncol = ncolf * esize + ncolo

    ret = [ndir, [nrow, ncol]]
    puts "cube wrap step returning #{ret.inspect}"
    ret
  end

  # edge size
  def esize
    return @esize if @esize
    # FIXME: only works for my sample and input map layout
    esize = [@rows.size / 3, @rows[0].size / 3].min
    puts "esize #{esize}" if $sus
    @esize = esize
  end
end

if $PROGRAM_NAME == __FILE__
  text = File.read(ARGV[0] || "input.txt")
  map_text, path_text = text.split("\n\n")

  debug = false
  if debug
    cmap = CubeMap.new(map_text, pass_thru_walls: true)
    # debug_steps = Step.parse("190R190R190")
    debug_steps = Step.parse("210L190")
    cmap.go(debug_steps)
    cmap.dump
    exit
  end

  steps = Step.parse(path_text.chomp)

  map = Map.new(map_text)
  map.go(steps)
  map.dump
  puts "Password: #{map.password}"

  cmap = CubeMap.new(map_text)
  cmap.go(steps)
  cmap.dump
  puts "Cube Password: #{cmap.password}"
end
