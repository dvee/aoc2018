require 'rgl/adjacency'
require 'rgl/traversal'
require 'rgl/dijkstra'
require 'set'

class RoomGraph

  attr_accessor :edges

  def initialize(re_str)
    @full_regex = re_str.freeze
    @str_pos = 0
    @edges = Set.new
    @move_count = 0
    parse_regex(re_str, 0, 0)
  end

  def parse_regex(re_str, x_pos, y_pos)
    s = re_str
    i = 0
    while i < s.size
      case c = s[i]
      when '(' #branch
        branches(s[i..-1]).each { |b| parse_regex(b, x_pos, y_pos) }
        return
      when /[NESW]/
          x_old, y_old = x_pos, y_pos
          x_pos, y_pos = move(x_pos, y_pos, c)
          @edges.add([[x_old, y_old], [x_pos, y_pos]])
      when '$'
        return
      end
      i += 1
    end
  end

  def branches(s)
    #e.g. (NEEE|SSE(EE|N)|)XXXYYYZZZ => ["NEEEXXXYYYZZZ", "SSE(EE|N)XXXYYYZZZ", "XXXYYYZZZ"]
    i = 1
    paren_count = 1
    current_group = ""
    groups = []
    while paren_count > 0
      if paren_count > 1
        current_group << s[i]
      else
        if s[i] == '|' #end of group
          groups << current_group
          current_group = ""
        else
          current_group << s[i]
        end
      end
      paren_count += 1 if s[i] == '('
      paren_count -= 1 if s[i] == ')'
      i += 1
    end

    #last group
    groups << current_group[0..-2] #ignore trailing )

    return groups.map{ |gr| gr + s[i..-1] }
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
#s = "^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$"
puts "exploring"
rg = RoomGraph.new(s)
puts "finding paths"
g = RGL::AdjacencyGraph.new
g.add_edges(*rg.edges)
paths = g.dijkstra_shortest_paths(Hash.new(1), [0,0])
puts paths.max_by{ |k,v| v.size }[1].size - 1
