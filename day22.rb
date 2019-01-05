DEPTH = 11817
TARGET = [9,751]

def geologic_index(x, y)
  @cache_g ||= Hash.new
  return @cache_g[[x, y]] || @cache_g[[x, y]] = begin
    if x == 0 && y == 0
      0
    elsif x == TARGET[0] and y == TARGET[1]
      0
    elsif y == 0
      x * 16807
    elsif x == 0
      y * 48271
    else
      erosion(x - 1, y) * erosion(x, y - 1)
    end
  end
end

def erosion(x, y)
  @cache_e ||= Hash.new
  return @cache_e[[x, y]] || @cache_e[[x, y]] = (geologic_index(x, y) + DEPTH) % 20183
end

def region_type(x, y)
  case erosion(x, y) % 3
  when 0
    '.'
  when 1
    '='
  when 2
    '|'
  end
end

def risk(x, y)
  erosion(x, y) % 3
end

grid = Array.new(TARGET[1] + 1) { Array.new(TARGET[0] + 1) { nil } }
risk_sum = 0

(0..TARGET[1]).each do |y|
  (0..TARGET[0]).each do |x|
    grid[y][x] = region_type(x, y)
    risk_sum += risk(x, y)
  end
end

puts grid.map(&:to_s).join("\n")
puts risk_sum

# part 2

# define state as [x, y, tool]
# tool:
#   c - climbing
#   t - torch
#   n - neither

# valid region type and tool combinations
# . :: c, t
# = :: c, n
# | :: t, n

require 'set'

# Increase the mapped area to ensure it includes the shortest path.
# Use the shortest path length within just the rectangle between source and target, P, to give
# a loose upper bound on the area required to guarantee the global shortest path is found.
# I.e. find P by running with x_dim = TARGET[0] + 1, y_dim = TARGET[1] + 1
P = 1051
x_dim = TARGET[0] + (P - (TARGET[0] + TARGET[1])) / 2
y_dim = TARGET[1] + (P - (TARGET[0] + TARGET[1])) / 2

valid_states = Array.new(y_dim) { Array.new(x_dim) { Array.new } }

edges = Set.new

(0...y_dim).each do |y|
  (0...x_dim).each do |x|
    valid_states[y][x] = case region_type(x, y)
    when '.'
      [[x, y, 'c'], [x, y, 't']]
    when '='
      [[x, y, 'c'], [x, y, 'n']]
    when '|'
      [[x, y, 't'], [x, y, 'n']]
    end

    #edge for tool transition in the same region
    edges.add(valid_states[y][x])

    #add edges for regions one position to the left and one position up
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
      valid_states[y][x].each do |s1|
        valid_states[y1][x1].each do |s2|
          if s1[2] == s2[2] #only allow transitions to new regions without switching tools
            edges.add([s1, s2])
          end
        end
      end
    end

  end
end

require 'rgl/adjacency'
require 'rgl/dijkstra'

g = RGL::AdjacencyGraph.new
g.add_edges(*edges)

class EdgeWeightMap
  def [](k)
    s1 = k[0]
    s2 = k[1]
    if s1[0] == s2[0] && s1[1] == s2[1] #tool change
      return 7
    else #move
      return 1
    end
  end
end
edge_weights = EdgeWeightMap.new

#there are two possible end states, at the target position with either a torch or climbing gear
path_t = g.dijkstra_shortest_path(edge_weights, [0,0,'t'], [TARGET[0],TARGET[1],'t'])
path_c = g.dijkstra_shortest_path(edge_weights, [0,0,'t'], [TARGET[0],TARGET[1],'c'])

[path_t, path_c].each do |p|
  puts p.each_cons(2).map { |s1, s2| edge_weights[[s1, s2]] }.sum
end
