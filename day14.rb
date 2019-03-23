PART = 2

class CircularLinkedList
  attr_reader :origin

  class Element
    attr_accessor :data, :next_element, :prev_element

    def initialize(data)
      @data = data
    end
  end

  def initialize(first_value)
    e = Element.new(first_value)
    @origin = e
    @origin.next_element = @origin
    @origin.prev_element = @origin
  end

  def add_after(q, data)
    e =  Element.new(data)
    e.prev_element = q
    e.next_element = q.next_element
    q.next_element.prev_element = e
    q.next_element = e
    return e
  end

  def add_before(q, data)
    e = Element.new(data)
    e.next_element = q
    e.prev_element = q.prev_element
    q.prev_element.next_element = e
    q.prev_element = e
    return e
  end

  def delete(q, inc_after_delete = true)
    q.prev_element.next_element = q.next_element
    q.next_element.prev_element = q.prev_element
    if inc_after_delete
      q.next_element
    else
      q.prev_element
    end
  end

  def next(q)
    q.next_element
  end

  def prev(q)
    q.prev_element
  end

  def to_a
    a = Array.new
    x = @origin
    loop do
      a << x.data
      x = self.next(x)
      break if x.equal?(@origin)
    end
    return a
  end

  def scan_for(arr)
    x = @origin
    i = 0
    loop do
      if x.data == arr[i]
        i += 1
      else
        i = 0
      end

      return true if i == arr.length

      x = self.next(x)
      break if x.equal?(@origin)
    end
    return false
  end

  def back_match(e_start, arr)
    a = arr.reverse
    x = e_start
    (0...arr.length).each do |i|
      return false if a[i] != x.data
      x = self.prev(x)
    end
  end

end

def new_recipe(a, b)
  s = (a + b).to_s
  return s.chars.map(&:to_i)
end

def print_list(list, start_of_list, end_of_list, elf1, elf2)
  op = []
  x = start_of_list
  loop do
    if x.equal?(elf1)
      op << "(#{x.data})"
    elsif  x.equal?(elf2)
      op << "[#{x.data}]"
    else
      op << "#{x.data}"
    end
    break if x.equal?(end_of_list)
    x = list.next(x)
  end
  puts op.join " "
end

l = CircularLinkedList.new(3)
elf_1_current = l.origin
elf_2_current = l.add_after(l.origin, 7)
eol = elf_2_current
n_elements = 2

print_list(l, l.origin, eol, elf_1_current, elf_2_current)

if PART == 1
  while n_elements < 909441  + 10
    new_recipe(elf_1_current.data, elf_2_current.data).each do |v|
      eol = l.add_after(eol, v)
      n_elements += 1
    end
    (elf_1_current.data + 1).times { elf_1_current = l.next(elf_1_current) }
    (elf_2_current.data + 1).times { elf_2_current = l.next(elf_2_current) }
    #print_list(l, l.origin, eol, elf_1_current, elf_2_current)
    puts n_elements
  end
  puts l.to_a[(-10..-1)].join("")
end



#part 2
if PART == 2
  a = "909441".chars.map(&:to_i)
  while !(l.back_match(eol, a) || l.back_match(l.prev(eol), a))
    new_recipe(elf_1_current.data, elf_2_current.data).each do |v|
      eol = l.add_after(eol, v)
      n_elements += 1
    end
    (elf_1_current.data + 1).times { elf_1_current = l.next(elf_1_current) }
    (elf_2_current.data + 1).times { elf_2_current = l.next(elf_2_current) }
    #print_list(l, l.origin, eol, elf_1_current, elf_2_current)
    #puts "#{n_elements} #{a.size}, #{n_elements - a.size}"
    puts n_elements if n_elements % 10000 == 0
  end
  puts "#{n_elements} #{a.size}, so #{n_elements - a.size} or #{n_elements - a.size - 1}"
end


