
class CircularLinkedList
  attr_reader :current_element

  class Element
    attr_accessor :data, :next_element, :prev_element

    def initialize(data)
      @data = data
    end
  end

  def initialize(first_value)
    e = Element.new(first_value)
    @current_element = e
    @current_element.next_element = @current_element
    @current_element.prev_element = @current_element
  end

  def add_after(data)
    e =  Element.new(data)
    e.prev_element = @current_element
    e.next_element = @current_element.next_element
    @current_element.next_element.prev_element = e
    @current_element.next_element = e
  end

  def add_before(data)
    e = Element.new(data)
    e.next_element = @current_element
    e.prev_element = @current_element.prev_element
    @current_element.prev_element.next_element = e
    @current_element.prev_element = e
  end

  def delete_current(inc_after_delete = true)
    @current_element.prev_element.next_element = @current_element.next_element
    @current_element.next_element.prev_element = @current_element.prev_element
    if inc_after_delete
      @current_element = @current_element.next_element
    else
      @current_element = @current_element.prev_element
    end
  end

  def inc
    @current_element = @current_element.next_element
  end

  def dec
    @current_element = @current_element.prev_element
  end
end

PLAYERS = 478
MARBLES = 100 * 71240

class Marbles
  attr_reader :player_totals

  def initialize
    @circle = CircularLinkedList.new(0)
    @count = 1
    @player_totals = Array.new(PLAYERS){0}
  end

  def turn
    if @count % 23 == 0
      @player_totals[@count % PLAYERS] += @count
      7.times { @circle.dec }
      additional_score = @circle.current_element.data
      @player_totals[@count % PLAYERS] += additional_score
      @circle.delete_current
    else
      @circle.inc
      @circle.add_after(@count)
      @circle.inc
    end
    @count += 1
  end
end

m = Marbles.new

(0..MARBLES).each do |i|
  m.turn
end

puts m.player_totals.to_s
puts m.player_totals.max



