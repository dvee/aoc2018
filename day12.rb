require 'pry'

f = File.read('input12.txt').split("\n")

initial_state = f[0].match(/initial state: (.*)/).captures[0]

rules = Hash.new
f[2..-1].each do |s|
  input, result = s.match(/(.*) => (.)/).captures
  rules[input] = result
end


current_state = initial_state.dup.prepend("....") << "...."
index_offset = -4
next_state = current_state.dup

puts "0: #{next_state}"

20.times do |t|
  (2..(next_state.size - 3)).each do |i|
    next_state[i] = rules[current_state[(i-2)..(i+2)]] || '.'
  end
  #puts "#{t + 1}: #{next_state}"
  puts t if t % 1000 == 0
  while next_state[0..4].include?('#')
    next_state.prepend(".")
    index_offset -= 1
  end

  while next_state[-5..-1].include?('#')
    next_state << "."
  end

  current_state = next_state.dup
end

s = 0
next_state.chars.each_with_index do |c, i|
  s += i + index_offset if c == '#'
end
puts s

puts rules

#part 2

# use some kind of linked list instead

# .. still too slow..

class DoublyLinkedListWithIndex
  include Enumerable

  attr_reader :current_element, :start_of_list, :end_of_list

  class Element
    attr_accessor :data, :index, :next_element, :prev_element

    def initialize(data, index)
      @data = data
      @index = index
    end
  end

  def initialize(arr)
    @start_of_list = Element.new(arr[0], 0)
    prev_e = @start_of_list

    i = 1
    arr[1..-1].each_with_index do |v|
      new_e = Element.new(v, i)
      prev_e.next_element = new_e
      new_e.prev_element = prev_e

      @end_of_list = new_e if i == arr.size - 1

      i += 1
      prev_e = new_e
    end
  end

  def append(v)
    new_end_of_list = Element.new(v, @end_of_list.index + 1)
    old_last_element = @end_of_list
    @end_of_list = new_end_of_list
    old_last_element.next_element = @end_of_list
    @end_of_list.prev_element = old_last_element
  end

  def prepend(v)
    new_start_of_list = Element.new(v, @start_of_list.index - 1)
    new_start_of_list.next_element = @start_of_list
    @start_of_list.prev_element = new_start_of_list
    @start_of_list = new_start_of_list
  end

  def inc
    @current_element = @current_element.next_element
  end

  def dec
    @current_element = @current_element.prev_element
  end

  def first(n=1)
    out = []
    e = @start_of_list
    n.times do
      out << e
      e = e.next_element
    end
    return out
  end

  def last(n=1)
    out = []
    e = @end_of_list
    n.times do
      out.unshift(e)
      e = e.prev_element
    end
    return out
  end

  def each
    @current_element = @start_of_list
    yield @current_element
    loop do
      @current_element = @current_element.next_element
      yield @current_element
      break if @current_element == @end_of_list
    end
  end
end

l = DoublyLinkedListWithIndex.new(initial_state.chars)

puts l.map{ |e| e.data }.to_s

def pad_ends(l1, l2)
  while l1.first(5).map{ |e| e.data }.include?('#')
    l1.prepend('.')
    l2.prepend('.')
  end

  while l2.last(5).map{ |e| e.data }.include?('#')
    l1.append('.')
    l2.append('.')
  end
end

def state_to_s(l)
  l.map{ |e| e.data }.to_s
end

current_state = DoublyLinkedListWithIndex.new(initial_state.chars)
next_state = DoublyLinkedListWithIndex.new(initial_state.chars)
pad_ends(next_state, current_state)

puts "0: #{state_to_s(next_state)}"

50000000000.times do |t|
  test_window = ["."] * 5
  e2 = next_state.start_of_list
  current_state.each do |e1|
    test_window.shift
    test_window.push(e1.next_element&.next_element&.data || '.')
    e2.data = rules[test_window.join("")] || '.'
    e2 = e2.next_element
  end

  pad_ends(next_state, current_state)
  current_state, next_state = next_state, current_state

  if t % 1000 == 0
    s = 0
    current_state.each do |e|
      s += e.index if e.data == '#'
    end
    puts "t:#{t}, s:#{s}"
  end
end


