
def read_map(filename)
  s = File.read(filename).split("\n")
  map = s.map{ |a| a.chars }
  map.each do |r|
    r.unshift(nil)
    r << nil
  end
  dim_x = map[0].size
  dim_y = map.size
  map.unshift(Array.new(dim_x) { nil })
  map << Array.new(dim_x) { nil }
  return map
end

def surrounding_elements(grid, x, y)
  return [grid[y-1][x-1], grid[y-1][x], grid[y-1][x+1],
          grid[y][x-1],                 grid[y][x+1],
          grid[y+1][x-1], grid[y+1][x], grid[y+1][x+1] ]
end

current_state = read_map('input18.txt')
next_state = read_map('input18.txt')

1140.times do |t|
  (1..(current_state.size - 2)).each do |y|
    (1..(current_state[0].size - 2)).each do |x|
      s = surrounding_elements(current_state, x, y)

      case current_state[y][x]
      when '.'
        if s.count('|') >= 3
          next_state[y][x] = '|'
        else
          next_state[y][x] = current_state[y][x]
        end
      when '|'
        if s.count('#') >= 3
          next_state[y][x] = '#'
        else
          next_state[y][x] = current_state[y][x]
        end
      when '#'
        if s.count('#') >= 1 && s.count('|') >= 1
          next_state[y][x] = '#'
        else
          next_state[y][x] = '.'
        end
      end
    end
  end
  current_state, next_state = next_state, current_state

  cs = current_state.flatten
  value = cs.count('#') * cs.count('|')

  #puts current_state.map { |a| a.join(' ') }

  puts "#{t+1}, #{value}"
end

# By inspection, for large t, value(t) is periodic with period 28. Pick a value
# of t=tc with (1000000000 - tc) % 28 == 0, e.g. tc = 1140
