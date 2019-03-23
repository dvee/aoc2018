require 'set'

class Computer
  attr_reader :r

  OPS = [:addi, :muli, :banr, :mulr, :bani, :borr, :bori, :setr, :seti, :gtir, :gtri, :addr, :eqir, :gtrr, :eqrr, :eqri]

  def initialize(a, b, c, d)
    @r = [a, b, c, d]
  end

  def addr(a, b, c)
    @r[c] = @r[a] + @r[b]
  end

  def addi(a, b, c)
    @r[c] = @r[a] + b
  end

  def mulr(a, b, c)
    @r[c] = @r[a] * @r[b]
  end

  def muli(a, b, c)
    @r[c] = @r[a] * b
  end

  def banr(a, b, c)
    @r[c] = @r[a] & @r[b]
  end

  def bani(a, b, c)
    @r[c] = @r[a] & b
  end

  def borr(a, b, c)
    @r[c] = @r[a] | @r[b]
  end

  def bori(a, b, c)
    @r[c] = @r[a] | b
  end

  def setr(a, b, c)
    @r[c] = @r[a]
  end

  def seti(a, b, c)
    @r[c] = a
  end

  def gtir(a, b, c)
    @r[c] = a > @r[b] ? 1 : 0
  end

  def gtri(a, b, c)
    @r[c] = @r[a] > b ? 1 : 0
  end

  def gtrr(a, b, c)
    @r[c] = @r[a] > @r[b] ? 1 : 0
  end

  def eqir(a, b, c)
    @r[c] = a == @r[b] ? 1 : 0
  end

  def eqri(a, b, c)
    @r[c] = @r[a] == b ? 1 : 0
  end

  def eqrr(a, b, c)
    @r[c] = @r[a] == @r[b] ? 1 : 0
  end

end

class Sample
  attr_reader :before, :command, :after
  def initialize(before, command, after)
    @before = before
    @command = command
    @after = after
  end
end

samples_s = File.read('input16a.txt').split("\n\n")
samples = samples_s.map do |s|
  b1, b2, b3, b4, c1, c2, c3, c4, a1, a2, a3, a4 = s.match(/Before:\s+\[(\d+), (\d+), (\d+), (\d+)\]\n(\d+) (\d+) (\d+) (\d+)\nAfter:\s+\[(\d+), (\d+), (\d+), (\d+)\]/m).captures.map(&:to_i)
  Sample.new([b1,b2,b3,b4], [c1,c2,c3,c4], [a1,a2,a3,a4])
end

num_matches = samples.map do |s|
  Computer::OPS.map do |method|
    c = Computer.new(*s.before)
    c.send(method, *s.command[1..3])
    c.r == s.after ? 1 : 0
  end.sum
end

puts num_matches.select{ |n| n >= 3 }.count

#part 2

codes_to_ops = Hash.new { |h,k| h[k] = Set.new }
samples.each do |s|
  opcode = s.command[0]
  Computer::OPS.each do |method|
    c = Computer.new(*s.before)
    c.send(method, *s.command[1..3])
    codes_to_ops[opcode].add(method) if c.r == s.after
  end
end

puts codes_to_ops

# hack to find perfect matching of bipartite graph for opcodes to methods
# pick vertices connected by a single edge, then remove any other edges
# corresponding to that method
while codes_to_ops.values.any? { |v| v.size > 1 }
  codes_to_ops.select{ |k,v| v.size == 1 }.each do |k,v|
    codes_to_ops.each do |kk, vv|
      codes_to_ops[kk] -= v if kk != k
    end
  end
  puts codes_to_ops
end

codes_to_ops.each { |k,v| codes_to_ops[k] = v.to_a[0] }

puts codes_to_ops


program = File.read('input16b.txt').split("\n")

c = Computer.new(0,0,0,0)
program.each do |p|
  command = p.match(/(\d+) (\d+) (\d+) (\d+)/).captures.map(&:to_i)
  c.send(codes_to_ops[command[0]], *command[1..3])
  puts c.r[0]
end
