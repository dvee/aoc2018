require 'set'

RUN = true
DEBUG = true
def debug(str)
  puts str if DEBUG
end

class Unit
  attr_reader :x, :y, :type, :map, :hp
  def initialize(x, y, type, map, attack_power: 3, hp: 200)
    @x = x
    @y = y
    @type = type
    @map = map
    @hp = hp
    @attack_power = attack_power
  end

  def reading_order_value
    y * grid.dx + x
  end

  def targets
    @map.units.select { |u| @type != u.type }
  end

  def open_target_squares
    targets.flat_map { |t| t.open_neighbouring_squares }
  end

  def neighbouring_positions
    [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]]
  end

  def open_neighbouring_squares
    neighbouring_positions.select do |x, y|
      @map.grid[y][x] == '.'
    end
  end

  def targets_already_in_range
    targets.select { |t| t.neighbouring_positions.include?(current_position) }
  end

  def reachable_target_paths
    shortest_paths.slice(*open_target_squares).select { |k, v| !v.nil? }
  end

  def reachable_target_squares
    reachable_target_paths.keys
  end

  def nearest_squares
    shortest_path = reachable_target_paths.min_by { |k, v| v[0].size }
    return unless shortest_path
    reachable_target_paths.select{ |k,v| !v.nil? && v[0].size == shortest_path[1][0].size }.keys
  end

  def choose_target_square
    return unless nearest_squares
    nearest_pos = nearest_squares.sort_by { |x, y| @map.reading_order_value(x, y) }.first
  end

  def choose_step(target_square)
    return unless target_square
    shortest_paths[target_square].map { |p| p[1] || target_square }.min_by { |x, y| @map.reading_order_value(x, y) }
  end

  def move(target)
    raise "invalid move" if (target[0] - x).abs + (target[1] - y).abs != 1
    @map.update_unit_position(self, target)
    @x = target[0]
    @y = target[1]
  end

  def choose_and_make_move
    debug "------------------"
    debug map.to_s_with_overlay(type.downcase, [current_position])
    next_step = choose_step(choose_target_square)
    move(next_step) if next_step
    debug ""
    debug map.to_s_with_overlay('X', [current_position])
  end

  def attack
    target = targets_already_in_range.sort do |t1, t2|
      if t1.hp == t2.hp
        map.reading_order_value(*t1.current_position) <=> map.reading_order_value(*t2.current_position)
      else
        t1.hp <=> t2.hp
      end
    end.first

    target.receive_damage(@attack_power) unless target.nil?
  end

  def receive_damage(attack_power)
    @hp -= attack_power
    @map.kill_unit(self) if @hp <= 0
  end

  def shortest_paths
    # graph where edges represent allowed moves between squares
    edges = Set.new

    (0...@map.dy).each do |y|
      (0...@map.dx).each do |x|
        neighbours = begin
          if x == 0 && y == 0
            []
          elsif x == 0
            [[x, y - 1]]
          elsif y == 0
            [[x - 1, y]]
          else
            [[x - 1, y], [x, y - 1]]
          end
        end

        neighbours.each do |x1, y1|
          edges.add([[x, y], [x1, y1]]) if @map.grid[y][x] == '.'  && @map.grid[y1][x1] == '.'
        end
      end
    end

    # add edges for source (starting) position
    neighbouring_positions.each do |x1, y1|
      edges.add([[x1, y1], [x, y]]) if @map.grid[y1][x1] == '.'
    end

    g = UnitAdjacencyGraph.new(edges)
    return g.shortest_paths([x, y])
  end

  def current_position
    [x, y]
  end

end

class Map
  attr_reader :grid, :dx, :dy, :units
  def initialize(map_data)
    @grid = map_data.split("\n").map do |s|
      s.chars.map do |c|
        case c
        when /[GE\.]/
          c
        when '#'
          '#'
        else
          raise "unknown map character #{c}"
        end
      end
    end

    @dx = grid[0].size
    @dy = grid.size

    @units = []
    grid.each_with_index do |row, y|
      row.each_with_index do |c, x|
        @units << Unit.new(x, y, c, self) if c =~ /[GE]/
      end
    end
  end

  def to_s
    @grid.map { |row| row.join "" }.join("\n") + "\n"
  end

  # print in aoc format, but replace output with the char `c` for each coordinate in coords
  #
  def to_s_with_overlay(c, coords)
    grid_dup =  Marshal.load(Marshal.dump(@grid))
    coords.each { |x, y| grid_dup[y][x] = c }
    grid_dup.map { |row| row.join "" }.join("\n") + "\n"
  end

  def reading_order_value(x, y)
    return y * @dx + x
  end

  def update_unit_position(unit, new_position)
    new_x, new_y = new_position
    raise "can't move unit to #{new_position}" if grid[new_y][new_x] != '.'
    grid[unit.y][unit.x] = '.'
    grid[new_y][new_x] = unit.type
  end

  def kill_unit(unit)
    @grid[unit.y][unit.x] = '.'
    @units.delete(unit)
  end

end

class Battle
  attr_reader :map
  def initialize(map_data)
    @map = Map.new(map_data)
  end

  def phase
    units_move_order = map.units.sort_by { |u| map.reading_order_value(u.x, u.y) }
    units_move_order.each do |unit|
      next unless map.units.include?(unit) #unit has already died during this phase
      puts "finding move for #{unit.current_position}"
      unit.choose_and_make_move if unit.targets_already_in_range.empty?
      unit.attack
    end
  end

  def run
    n_phase = 0
    while map.units.count{ |u| u.type == 'G' } > 0 && map.units.count{ |u| u.type == 'E' } > 0
      phase
      n_phase += 1
      puts "after #{n_phase} rounds"
      puts self
    end

    outcome = n_phase * @map.units.sum { |u| u.hp }
    puts "outcome: #{outcome}"
    return outcome
  end

  def to_s
    (0...@map.dy).map do |y|
      units_health_str = @map.units.select{ |u| u.y == y }.map{ |u| "#{u.type}(#{u.hp})"}.join ", "
      @map.grid[y].join("") + "    " + units_health_str
    end.join "\n"
  end
end

class UnitAdjacencyGraph
  attr_reader :vertices
  def initialize(edges)
    @vertices = Hash.new { |h, k| h[k] = Vertex.new(k) }
    edges.each do |e|
      @vertices[e[0]].add_neighbour(@vertices[e[1]])
      @vertices[e[1]].add_neighbour(@vertices[e[0]])
    end
  end

  ##
  # calculates shortest paths to each vertex from start.
  # returns a hash with keys as the target, and values as the list of all
  # paths having the shortest length. A path is a list of vertices traversed
  # to get to the target.
  def shortest_paths(start)
    paths = Hash.new
    @vertices.values.each { |v| paths[v] = [[]] }
    visited = Set.new
    queue = [@vertices[start]]
    while !queue.empty?
      current_vertex = queue.shift
      next if visited.include?(current_vertex)
      current_vertex.neighbours.each do |v|
        next if visited.include?(v)
        if paths[v][0].empty? || paths[v][0].size > paths[current_vertex][0].size + 1
          paths[v] = paths[current_vertex].map { |p| p.dup << current_vertex }
        elsif paths[v][0].size == paths[current_vertex][0].size + 1
          paths[v] += paths[current_vertex].map { |p| p.dup << current_vertex }
        end
        queue.push(v)
      end
      visited.add(current_vertex)
      puts visited.size
    end

    # map back to original "id" domain
    out = Hash.new
    paths.each do |vertex, ps|
      out[vertex.id] = ps.map do |p|
        p.map do |v|
          v.id
        end
      end
      out[vertex.id] = nil if ps[0].empty?
    end
    out
  end

  class Vertex
    attr_reader :id
    attr_accessor :neighbours
    def initialize(id)
      @id = id
      @neighbours = Set.new
    end

    def add_neighbour(vertex)
      @neighbours.add(vertex)
    end

    def eql?(other_key)
      id == other_key.id
    end

    def hash
      id.hash
    end

    def inspect
      id
    end
  end
end

if RUN
  my_input = <<-'DATA'
################################
#######..G######################
########.....###################
##########....############.....#
###########...#####..#####.....#
###########G..###GG....G.......#
##########.G#####G...#######..##
###########...G.#...############
#####.#####..........####....###
####.....###.........##.#....###
####.#................G....#####
####......#.................####
##....#G......#####........#####
########....G#######.......#####
########..G.#########.E...######
########....#########.....######
#######.....#########.....######
#######...G.#########....#######
#######...#.#########....#######
####.G.G.....#######...#.#######
##...#...G....#####E...#.#######
###..#.G.##...E....E.......###.#
######...................#....E#
#######...............E.########
#G###...#######....E...#########
#..##.######.E#.#.....##########
#..#....##......##.E...#########
#G......###.#..##......#########
#....#######....G....E.#########
#.##########..........##########
#############.###.......########
################################
DATA
  battle = Battle.new(my_input)
  battle.run
end
