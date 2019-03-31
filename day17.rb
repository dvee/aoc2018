test_data = <<-'DATA'
x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504
DATA

class Prob17
  attr_reader :grid

  def initialize(data)
    clay = data.split("\n").map do |s|
      x_r = s.match(/x=(\d+)\.?\.?(\d+)?/).captures.map { |c| c.to_i unless c.nil? }
      y_r = s.match(/y=(\d+)\.?\.?(\d+)?/).captures.map { |c| c.to_i unless c.nil? }
      [x_r, y_r]
    end
    x_min = clay.map{ |c| c[0][0] }.min - 2
    x_max = clay.map{ |c| c[0][1].nil? ? c[0][0] : c[0][1] }.max + 2
    y_min = 0
    y_max = clay.map{ |c| c[1][1].nil? ? c[1][0] : c[1][1] }.max + 2

    grid = Array.new(y_max - y_min) { Array.new(x_max - x_min) { '.' } }
    y_offset = y_min
    x_offest = x_min

    clay.each do |x_r, y_r|
      if x_r.include?(nil)
        x = x_r[0]
        Range.new(*y_r).each do |y|
          grid[y - y_offset][x - x_offest] = '#'
        end
      else
        y = y_r[0]
        Range.new(*x_r).each do |x|
          grid[y - y_offset][x - x_offest] = '#'
        end
      end
    end

    @count_area_min_y = clay.map { |x_r, y_r| y_r.select{ |y| !y.nil? }.min  }.min

    @spring_x = 500 - x_offest
    @spring_y = 0 - y_offset

    grid[@spring_y][@spring_x] = '+'
    @grid = grid
    @pool_queue = []
  end

  def print_grid
    puts @grid.map(&:join).join "\n"
  end

  def print_grid_segment(x_range, y_range)
    x_min = [0, x_range.first].max
    x_max = [@grid[0].size - 1, x_range.last].min
    y_min = [0, y_range.first].max
    y_max = [@grid.size - 1, y_range.last].min
    puts @grid[(y_min..y_max)].map{ |r| r[x_min..x_max].join }.join "\n"
  end

  def flow(x, y, from)
    if @count % 1000000 == 0
      puts "#{y} / #{@grid.size}, #{water_count}"
      f = File.open("17out.txt", 'w')
      f << @grid.map(&:join).join("\n")
      f.close()
    end
    @count += 1

    segment_size = 10
    #print_grid_segment((x - segment_size)..(x + segment_size), (y - segment_size)..(y + segment_size))
    #@pool_queue << y if ['e', 'w'].include?(from)
    @grid[y][x] = '|' unless @grid[y][x] == 'x'
    return if y >= @grid.size - 2

    # w - c - e
    #     |
    # sw  s   se
    neighbour_value = lambda do |direction|
      case direction
      when 'c' then @grid[y][x]
      when 'w' then @grid[y][x - 1]
      when 's' then @grid[y + 1][x]
      when 'e' then @grid[y][x + 1]
      when 'se' then @grid[y + 1][x + 1]
      when 'sw' then @grid[y + 1][x - 1]
      end
    end

    if can_flow_to?(neighbour_value['s'])
      flow(x, y + 1, 'n')
      run_pooling
    else
      @pool_queue << y
    end

    if from != 'w' && can_flow_to?(neighbour_value['w']) && (is_supportive?(neighbour_value['s']))
      flow(x - 1, y, 'e')
    end

    if from != 'e' && can_flow_to?(neighbour_value['e']) && (is_supportive?(neighbour_value['s']))
      flow(x + 1, y, 'w')
    end

  end

  def can_flow_to?(c)
    ['.', '|'].include?(c)
  end

  def is_supportive?(c)
    ['~','#'].include?(c)
  end

  def pool(y)
    pooled = false
    while xs = (@grid[y].join("") =~ /#\|+#/)
      xs += 1
      while @grid[y][xs] == '|'
        pooled = true
        @grid[y][xs] = '~'
        xs += 1
      end
    end
    @pool_queue << y - 1 if pooled
  end

  def run_pooling
    @pool_queue.uniq!
    while y = @pool_queue.shift
      pool(y)
    end
  end

  def run
    @count = 1
    puts "flowing.."
    flow(@spring_x, @spring_y + 1, 'n')
    puts water_count
    puts @count
    #print_grid
  end

  def water_count
    @grid[@count_area_min_y..-1].map { |row| row.count { |c| ['~', '|'].include?(c) } }.sum
  end
end

p = Prob17.new(File.read("input17.txt"))
#p = Prob17.new(test_data)
p.run
