require 'pry'

f = File.read("input10.txt").split("\n")


class Point
  attr_accessor :x, :y, :vx, :vy

  def initialize(x,y,vx,vy)
    @x = x.to_i
    @y = y.to_i
    @vx = vx.to_i
    @vy = vy.to_i
  end

  def step
    @x += vx
    @y += vy
  end

  def to_s
    "p:<#{x}, #{y}> v:<#{vx}, #{vy}>"
  end

end

points = f.map do |s|
  Point.new(*s.match(/position=< *(-?\d+), *(-?\d+)> velocity=< *(-?\d+), *(-?\d+)>/).captures)
end

puts points.to_s

def get_grid_size(points)
  x_s = points.map { |p| p.x }
  y_s = points.map { |p| p.y }

  x_offset = x_s.min
  y_offset = y_s.min
  x_range = x_s.max - x_offset
  y_range = y_s.max - y_offset

  return x_range * y_range
end

def get_grid(points)
  x_s = points.map { |p| p.x }
  y_s = points.map { |p| p.y }

  x_offset = x_s.min
  y_offset = y_s.min
  x_range = x_s.max - x_offset
  y_range = y_s.max - y_offset

  puts "grid size: #{y_range} x #{x_range}"

  grid = Array.new(y_range + 1){ Array.new(x_range + 1) { '.' } }

  #puts "#{y_offset} #{x_offset} #{y_range} #{x_range}"

  points.each { |p|
    #puts "#{p.y} #{p.x} #{p.y - y_offset} #{p.x - x_offset} "
    grid[p.y - y_offset][p.x - x_offset] = '#' }

  return grid
end


def print_grid(g)
  g.each { |gg| puts gg.to_s }
end

grids = []
10243.times do |i|
  #g = get_grid(points)
  #grids << [g.size * g.first.size, g.dup]
  #print_grid(g)
  #puts [i, get_grid_size(points)].to_s
  grids << [i, get_grid_size(points)]
  points.each { |p| p.step }
end

g = get_grid(points)
print_grid(g)

#print_grid(grids.min_by { |g| g[0] }[1])
#puts grids
#puts grids.min_by { |g| g[1] }

