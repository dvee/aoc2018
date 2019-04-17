
PLAYERS = 478
MARBLES = 71240

class Marbles
  attr_reader :player_totals

  def initialize
    @circle = [0]
    @current_marble_i = 0
    @count = 1
    @player_totals = Array.new(PLAYERS){0}
  end

  def turn
    #print_state
    #puts @count
    if @count % 23 == 0
      @player_totals[@count % PLAYERS] += @count
      delete_ind = (@current_marble_i - 7) % @circle.length
      additional_score = @circle.delete_at(delete_ind)
      @player_totals[@count % PLAYERS] += additional_score
      @current_marble_i = delete_ind % @circle.length
      puts "count: #{@count}, #{@circle[@current_marble_i]}, +score: #{additional_score}"
    else
      insert_pos = (@current_marble_i + 2) % @circle.length
      @circle.insert(insert_pos, @count)
      @current_marble_i = insert_pos
    end
    @count += 1
  end

  def print_state
    s = ""
    s << "[#{@count % PLAYERS}] "
    @circle.each_with_index do |c, i|
      if @current_marble_i == i
        s << "(#{c}) "
      else
        s << "#{c} "
      end
    end
    puts s
  end
end

m = Marbles.new

#(0..MARBLES).each do |i|
(0..1000).each do |i|
  m.turn
end

puts m.player_totals.to_s
puts m.player_totals.max
