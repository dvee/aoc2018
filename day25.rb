require 'rgl/adjacency'
require 'rgl/connected_components'
require 'set'

points = File.read('input25.txt').split("\n").map{ |s| s.match(/(-?\d+),(-?\d+),(-?\d+),(-?\d+)/).captures.map(&:to_i) }

edges = Set.new

def l1(a, b)
  a.zip(b).map { |x, y| (x - y).abs }.sum
end

#contruct undirected graph where edges connect points in range

points.combination(2).each do |a, b|
  edges.add([a, b]) if l1(a,b) <= 3
end

#find number of connected components with a depth first search

def dfs(v, edges, visited)
  visited.add(v)
  edges.select{ |e| e.include?(v) }.each do |e|
    w = e.find{ |vv| vv != v }
    dfs(w, edges, visited) unless visited.include?(w)
  end
end

visited = Set.new
components = 0
points.each do |v|
  if !visited.include?(v)
    components += 1
    dfs(v, edges, visited)
  end
end
puts components

