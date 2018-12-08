require 'set'

s = File.read('input6.txt').split("\n")

class Point
  attr_reader :x, :y, :neighbours
  def initialize(x, y)
    @x = x.to_i
    @y = y.to_i
  end

  def distance_to(xx, yy)
    return (xx - x).abs + (yy - y).abs
  end
end

points = s.map do |sp|
  Point.new(*sp.match(/(\d+), (\d+)/).captures)
end

x_offset = points.min_by { |p| p.x }.x
y_offset = points.min_by { |p| p.y }.y

x_max = points.max_by { |p| p.x }.x - x_offset
y_max = points.max_by { |p| p.y }.y - y_offset

# set origin so upper leftmost point is (0,0)

points = points.map{ |p| Point.new(p.x - x_offset, p.y - y_offset) }

grid = Array.new(y_max+1){ Array.new(x_max+1) }

points.each_with_index do |p, ip|
  grid[p.y][p.x] = ip
end

grid.each_with_index do |gy, y|
  gy.each_with_index do |g, x|
    distances = Hash.new
    points.each_with_index do |p, ip|
      distances[ip] = p.distance_to(x, y)
    end
    distances_arr = distances.sort_by{ |k,v| v }
    if distances_arr[0][1] == distances_arr[1][1]
      grid[y][x] = -1
    else
      grid[y][x] = distances_arr[0][0]
    end
  end
end

on_outside = Set.new

grid[0].each { |x| on_outside.add(x) }
grid[-1].each { |x| on_outside.add(x) }
(0..y_max).each { |y|
  on_outside.add(grid[y][0])
  on_outside.add(grid[y][x_max])
}

counts = Hash.new(0)

grid.each do |g|
  g.each do |v|
    counts[v] += 1
  end
end

counts_arr = counts.sort_by{ |k,v| v }

valid_counts_arr = counts_arr.map{ |ip, count| [ip, count] if !on_outside.include?(ip) && ip != -1 }

puts valid_counts_arr.to_s

#part 2

distance_threshold = 10000

grid_total = Array.new(y_max+1){ Array.new(x_max+1) { 0 } }

less_than_thresh = 0

(0..y_max).each do |y|
  (0..x_max).each do |x|
    points.each do |p|
      grid_total[y][x] += p.distance_to(x, y)
    end
    less_than_thresh += 1 if grid_total[y][x] < distance_threshold
  end
end

puts less_than_thresh
