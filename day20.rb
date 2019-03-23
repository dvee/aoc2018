require 'rgl/adjacency'
require 'rgl/traversal'
require 'rgl/dijkstra'
require 'set'

class RoomGraph

  attr_accessor :edges

  def initialize(re_str)
    @full_regex = re_str.freeze
    @i_regex = 0
    @edges = Set.new
    @move_count = 0
    explore_from([[0,0]])
  end

  def explore_from(positions)
    prev_positions = positions.map(&:dup)
    new_branch_positions = []
    loop do
      @i_regex += 1
      case c = @full_regex[@i_regex]
      when /[NESW]/
        positions.each do |p|
          p_new = move(p[0], p[1], c)
          @edges.add([p.dup, p_new.dup])
          p[0], p[1] = p_new[0], p_new[1]
        end
      when '(' #branch
        positions = explore_from(positions)
      when '|'
        new_branch_positions |= positions
        positions = prev_positions.map(&:dup)
      when ')'
        new_branch_positions |= positions
        break
      when '$'
        return
      end
    end
    return new_branch_positions
  end

  def move(x_pos, y_pos, direction)
    case direction
    when 'N'
      y_pos +=1
    when 'S'
      y_pos -=1
    when 'E'
      x_pos += 1
    when 'W'
      x_pos -= 1
    else
      raise ArgumentError.new("#{direction} is not a valid direction")
    end

    @move_count += 1
    puts @move_count
    return x_pos, y_pos
  end

end

s = File.read('input20.txt')
puts "exploring"
rg = RoomGraph.new(s)
puts "finding shortest paths"
g = RGL::AdjacencyGraph.new
g.add_edges(*rg.edges)
paths = g.dijkstra_shortest_paths(Hash.new(1), [0,0])
puts paths.max_by{ |k,v| v.size }[1].size - 1
puts paths.select{ |k,v| v.size > 1000 }.count
