SERIAL = 3031

def calc_power(x,y, serial=SERIAL)
  rack_id = x + 10
  p = rack_id * y
  p += serial
  p = p * rack_id
  p = p.to_s[-3].to_i
  p -= 5
end

grid = Array.new(301) { Array.new(301) }

(1..300).each do |y|
  (1..300).each do |x|
    grid[y][x] = calc_power(x,y)
  end
end

cell_values = Array.new(301) { Array.new(301) { 0 } }

max_val = 0
max_coord = []

(1..298).each do |y|
  (1..298).each do |x|
    cell_values[y][x] = grid[y][x] + grid[y][x + 1] + grid[y][x + 2] + grid[y + 1][x] + grid[y + 1][x + 1] + grid[y + 1][x + 2] + grid[y+2][x] + grid[y+2][x+1] + grid[y+2][x+2]
    if cell_values[y][x] > max_val
      max_val = cell_values[y][x]
      max_coord = [x,y]
    end
  end
end

puts max_val
puts max_coord.to_s

#part 2

#integral image
s = Array.new(301) { Array.new(301) { 0 } }

(1..300).each do |y|
  (1..300).each do |x|
    s[y][x] = grid[y][x] + s[y][x - 1] + s[y - 1][x] - s[y-1][x-1]
  end
end


def sum_square(s, x, y, size)
  return s[y - 1][x - 1] + s[y + size - 1][x + size - 1] - s[y + size -1][x - 1] - s[y - 1][x + size - 1]
end

puts "testing sum_square function: #{sum_square(s, 21, 76, 3)}"

max_s = -Float::INFINITY
max_s_coord = []

(1..300).each do |y|
  (1..300).each do |x|
    (1..[301 - x, 301 - y].min).each do |size|
      pwr = sum_square(s, x, y, size)
      if pwr > max_s
        max_s = pwr
        max_s_coord = [x, y, size]
      end
    end
  end
end

puts "pwr: #{max_s}, coord: #{max_s_coord}"
