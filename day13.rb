require 'pry'

class Car
  include Comparable

  attr_reader :x, :y, :direction
  attr_accessor :has_ticked

  def initialize(x:, y:, direction:)
    @x = x
    @y = y
    @direction = direction
    @turn_cycle = ['left', 'straight', 'right'].cycle
    @has_ticked = false
  end

  def <=>(other_car)
    if self.y >= other_car.y && self.x > other_car.x
      return 1
    elsif self.y == other_car.y && self.x == other_car.x
      return 0
    else
      return -1
    end
  end

  def move(track)
    case @direction
    when '>'
      @x += 1
    when '<'
      @x -= 1
    when 'v'
      @y += 1
    when '^'
      @y -= 1
    end

    #determine new direction, if any
    @direction = case track[@y][@x]
    when "\\"
      case @direction
      when '>'
        'v'
      when 'v'
        '>'
      when '<'
        '^'
      when '^'
        '<'
      end
    when "/"
      case @direction
      when '>'
        '^'
      when 'v'
        '<'
      when '<'
        'v'
      when '^'
        '>'
      end
    when '+'
      case @turn_cycle.next
      when 'left'
        case @direction
        when '>'
          '^'
        when 'v'
          '>'
        when '<'
          'v'
        when '^'
          '<'
        end
      when 'straight'
        @direction
      when 'right'
        case @direction
        when '>'
          'v'
        when 'v'
          '<'
        when '<'
          '^'
        when '^'
          '>'
        end
      end
    else
      @direction
    end
  end
end

class Simulation

  class CollisionError < StandardError
    def initialize(car)
      super("Collision at #{car.x}, #{car.y}")
    end
  end

  def initialize(filename, part=1)
    lines = File.read(filename).split("\n")

    @track = Array.new(lines.size) { Array.new(lines.map(&:size).max) { '.' } }
    @cars = Array.new
    @part = part

    lines.each_with_index do |l, y|
      l.chars.each_with_index do |c, x|
        @track[y][x] = c
        if ['^', 'v', '<', '>'].include?(@track[y][x])
          @cars << Car.new(x: x, y: y, direction: c)
          @track[y][x] = '|'
        end
      end
    end
  end

  def print_state
    output = Array.new(@track.size) { Array.new(@track[0].size) { ' ' } }
    @track.each_with_index do |r, y|
      r.each_with_index do |v, x|
        output[y][x] = v
      end
    end
    @cars.each { |c| output[c.y][c.x] = c.direction }
    puts output.map{ |l| l.join(' ') }
  end

  def tick
    @cars.each { |c| c.has_ticked = false }
    @cars.sort!
    i = 0
    while i < @cars.size
      c = @cars[i]
      c.move(@track) if !c.has_ticked
      c.has_ticked = true
      #check for collisions
      if @part == 1
        raise CollisionError.new(c) if @cars.select{ |cc| c == cc }.size > 1
      else
        if @cars.select{ |cc| c == cc }.size > 1
          @cars.delete(c)
          i = 0
        end
      end
      i += 1
    end
    if @cars.size == 1
      puts "last car remaining at #{@cars.first.x}, #{@cars.first.y}"
      exit(0)
    end
  end

  def run
    loop do
      print_state if @part == 1
      tick
      if @part == 2
        puts "cars remaining: #{@cars.size}"
        @cars.each do |c|
          puts "#{c.x}, #{c.y}, #{c.direction}"
        end
      end
    end
  end
end

s = Simulation.new('input13.txt', 2)
s.run
#44, 57
