class LinkedListWithIndex
  attr_reader :start_of_list, :end_of_list

  class Element
    attr_accessor :data, :index, :next_element

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
  end

  def prepend(v)
    new_start_of_list = Element.new(v, @start_of_list.index - 1)
    new_start_of_list.next_element = @start_of_list
    @start_of_list = new_start_of_list
  end

  def next(q)
    q.next_element
  end

  def to_a
    a = Array.new
    x = @start_of_list
    loop do
      a << [x.index, x.data]
      break if x.equal?(@end_of_list)
      x = self.next(x)
    end
    return a
  end

  def first(n=1)
    out = []
    e = @start_of_list
    n.times do
      out << e
      e = e.next_element
    end
  end
end
