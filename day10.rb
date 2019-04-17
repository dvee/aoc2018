INPUT_FILE = "input10.txt"

def read_input(filename)
  File.read(filename).split("\n").map do |s|
    Point.new(*s.match(/position=< *(-?\d+), *(-?\d+)> velocity=< *(-?\d+), *(-?\d+)>/).captures)
  end
end

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

points = read_input(INPUT_FILE)

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

  points.each { |p| grid[p.y - y_offset][p.x - x_offset] = '#' }

  return grid
end


def print_grid(g)
  g.each { |gg| puts gg.to_s }
end

# Find when the grid of points are most "orderly".
# Try using grid size as a measure of disorder, i.e. minimize grid size.

grids = []

50000.times do |i|
  grids << [i, get_grid_size(points)]
  points.each { |p| p.step }
end

n_star = grids.min_by { |i, size| size }[0]

puts n_star

#restart and move n_star steps
points = read_input(INPUT_FILE)

n_star.times do |i|
  points.each { |p| p.step }
end

g = get_grid(points)
print_grid(g)
