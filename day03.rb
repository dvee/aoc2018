DIM = 1000

class Claim
  attr_reader :id, :x, :y, :width, :height

  def initialize(s)
    @id, @x, @y, @width, @height = s.match(/^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/).captures.map(&:to_i)
  end
end

claims = File.read('input3.txt').split("\n").map{ |s| Claim.new(s) }
grid = Array.new(DIM){ Array.new(DIM) { 0 } }

def apply_claim(claim:, grid:)
  grid[claim.y...(claim.y + claim.height)].each_with_index do |row, i|
    (claim.x...(claim.x + claim.width)).each do |j|
      row[j] += 1
    end
  end
end

claims.each { |c| apply_claim(claim: c, grid: grid) }


puts grid.flatten.map{ |x| x > 1 ? 1 : 0}.sum

#part 2:

def claim_uncontested?(claim:, grid_claimed:)
  grid_claimed[claim.y...(claim.y + claim.height)].each_with_index do |row, i|
    (claim.x...(claim.x + claim.width)).each do |j|
      return false if row[j] > 1
    end
  end
  return true
end

claims.each do |c|
  puts "claim #{c.id} uncontested!" if claim_uncontested?(claim: c, grid_claimed: grid)
end
