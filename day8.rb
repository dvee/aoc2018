
s = File.read('input8.txt').strip.split(" ").map(&:to_i)

class Node
  attr_reader :children
  attr_reader :data

  def initialize(s)
    @n_children = s[0]
    @n_data = s[1]
    @children = []
    @data = []

    children_added = 0
    s.slice!(0..1)
    while children_added < @n_children
      @children << Node.new(s)
      children_added += 1
    end

    data_added = 0
    while data_added < @n_data
      @data << s[0]
      s.slice!(0)
      data_added += 1
    end
  end

  def get_all_data()
    arr = []
    arr += data
    children.each { |c| arr += c.get_all_data() } unless children.empty?
    return arr
  end

  def value
    return data.sum if children.empty?
    v = 0
    data.each{ |d| v += children[d-1].value if d <= children.size && d > 0 }
    return v
  end

end

root_node = Node.new(s)

puts root_node.get_all_data().sum

#part 2:

puts root_node.value
