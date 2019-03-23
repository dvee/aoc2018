require 'pry'
require 'set'

class Computer
  attr_reader :r

  OPS = [:addi, :muli, :banr, :mulr, :bani, :borr, :bori, :setr, :seti, :gtir, :gtri, :addr, :eqir, :gtrr, :eqrr, :eqri]

  def initialize(r = [0] * 6)
    @r = r
    @ip = nil
    @prev_states = Set.new
    @instruction_count = 0
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

  def run(program)
    @ip = program.ip_addr
    while r[@ip] < program.instructions.size
      instruction = program.fetch r[@ip]
      output = "ip: #{@r[@ip]} #{@r} #{instruction[0]} #{instruction[1]} "
      #binding.pry
      self.send(instruction[0], *instruction[1])
      output << "=> #{@r}"
      puts output
      r[@ip] += 1
      @instruction_count += 1
      if !@prev_states.add?(@r.dup)
        puts "Repeated state #{@r} after #{@instruction_count} instructions"
        return [@r, @instruction_count]
      end
    end
  end

end

class Program
  attr_reader :ip_addr, :instructions
  def initialize(filename)
    f = File.read(filename).split("\n")
    @ip_addr = f[0].match(/#ip (\d+)/).captures[0].to_i
    @instructions = f[1..-1].map do |s|
      command, a, b, c = s.match(/(\w+) (\d+) (\d+) (\d+)/).captures
      [command.to_sym, [a, b, c].map(&:to_i)]
    end
  end

  def fetch(i)
    return instructions[i]
  end
end

p = Program.new('input21.txt')
c = Computer.new([0,0,0,0,0,0])
c.run(p)
