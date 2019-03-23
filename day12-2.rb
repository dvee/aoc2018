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
s_1 = 0

3000.times do |t|
  (2..(next_state.size - 3)).each do |i|
    next_state[i] = rules[current_state[(i-2)..(i+2)]] || '.'
  end

  while next_state[0..4].include?('#')
    next_state.prepend(".")
    current_state.prepend(".")
    index_offset -= 1
  end

  while next_state[-5..-1].include?('#')
    next_state << "."
    current_state << "."
  end

  current_state, next_state = next_state, current_state


  s = 0
  current_state.chars.each_with_index do |c, i|
    s += i + index_offset if c == '#'
  end
  puts "#{t}, #{s}, #{s - s_1}"
  s_1 = s

end

s = 0
current_state.chars.each_with_index do |c, i|
  s += i + index_offset if c == '#'
end
puts s

#for large t, a steady state is reached where each time step adds 33 plants. Use s at t=3000 to calculate
# s at 50000000000:

puts s + (50000000000 - 3000) * 33
