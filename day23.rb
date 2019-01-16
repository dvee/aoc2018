f = File.read('input23.txt').split("\n")

class NanoBot
  attr_reader :x, :y, :z, :r
  def initialize(x, y, z, r)
    @x = x.to_i
    @y = y.to_i
    @z = z.to_i
    @r = r.to_i
  end

  def distance_to(other)
    return (x - other.x).abs + (y - other.y).abs + (z - other.z).abs
  end

  def corners
    return [[@x + @r, @y, @z], [@x - @r, @y, @z],
            [@x, @y + @r, @z], [@x, @y - @r, @z],
            [@x, @y, @z + @r], [@x, @y, @z - @r]]
  end

  def in_range(x, y, z)
    (@x - x).abs + (@y - y).abs + (@z - z).abs <= @r
  end
end

nanobots = f.map { |s| NanoBot.new(*s.match(/pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)/).captures) }
strongest = nanobots.max_by { |b| b.r }
puts nanobots.count { |b| strongest.distance_to(b) <= strongest.r }

#part 2

#search space

x_range = [nanobots.min_by { |b| b.x }.x, nanobots.max_by { |b| b.x }.x]
y_range = [nanobots.min_by { |b| b.y }.y, nanobots.max_by { |b| b.y }.y]
z_range = [nanobots.min_by { |b| b.z }.z, nanobots.max_by { |b| b.z }.z]

puts "#{x_range} #{y_range} #{z_range}"

class SearchCube
  attr_reader :x0, :x1, :y0, :y1, :z0, :z1
  def initialize(x0, x1, y0, y1, z0, z1)
    @x0 = x0
    @x1 = x1
    @y0 = y0
    @y1 = y1
    @z0 = z0
    @z1 = z1
  end

  def split
    xm = (x1 + x0) / 2
    ym = (y1 + y0) / 2
    zm = (z1 + z0) / 2
    return [[x0, xm, y0, ym, z0, zm],
            [xm + 1, x1, y0, ym, z0, zm],
            [x0, xm, ym + 1, y1, z0, zm],
            [xm + 1, x1, ym + 1, y1, z0, zm],
            [x0, xm, y0, ym, zm + 1, z1],
            [xm + 1, x1, y0, ym, zm + 1, z1],
            [x0, xm, ym + 1, y1, zm + 1, z1],
            [xm + 1, x1, ym + 1, y1, zm + 1, z1]
           ].map { |a| SearchCube.new(*a) }
  end

  def volume
    return (x1 - x0) * (y1 - y0) * (z1 - z0)
  end

  def distance_to_origin
    [[x0, y0, z0],
     [x1, y0, z0],
     [x0, y1, z0],
     [x1, y1, z0],
     [x0, y0, z1],
     [x1, y0, z1],
     [x0, y1, z1],
     [x1, y1, z1]].map { |a| a.sum { |v| v.abs } }.min
  end
end

def nanobot_range_within_cube?(nanobot, cube)
  distance = [
    cube.x0 - nanobot.x,
    nanobot.x - cube.x1,
    cube.y0 - nanobot.y,
    nanobot.y - cube.y1,
    cube.z0 - nanobot.z,
    nanobot.z - cube.z1
  ].select { |v| v > 0 }.sum

  return distance <= nanobot.r
end

initial_cube = SearchCube.new(*[x_range, y_range, z_range].flatten)
queue = [[initial_cube, nanobots.count { |n| nanobot_range_within_cube?(n, initial_cube) }]]

c = nil
loop do
  queue.sort! do |a, b|
    if a[1] == b[1]
      a[0].distance_to_origin <=> b[0].distance_to_origin
    else
      a[1] <=> b[1]
    end
  end

  c = queue.pop[0]
  break if c.volume == 0

  c.split.each do |s|
    count = nanobots.count { |n| nanobot_range_within_cube?(n, s) }
    puts "[#{s.x0}, #{s.y0}, #{s.z0}] #{count}, #{s.volume}"
    queue.push([s, count])
  end
end

puts [c.x0, c.y0, c.z0].to_s
puts [c.x0, c.y0, c.z0].sum
