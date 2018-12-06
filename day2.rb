boxes = File.read('input2.txt').split("\n")

def letter_count(s)
  h = Hash.new(0)
  s.split('').each{ |c| h[c] += 1}
  return h
end

def my_checksum(s)
  a = 0
  b = 0
  letter_count(s).each do |k,v|
    a = 1 if v == 2
    b = 1 if v == 3
  end
  return [a,b]
end

check = boxes.map { |s| my_checksum(s) }.reduce([0 ,0]){ |m, c|
  m[0] += c[0]
  m[1] += c[1]
  m }


puts "Part 1: #{check[0] * check[1]}"

h = Hash.new(0)
boxes.each do |b|
  (0...(b.length)).each do |i|
    cut_string = b.dup
    cut_string.slice!(i)
    k = cut_string + "&#{i}" #append position of removed character to produce composite key
    h[k] += 1
    puts "Part 2 candidate: #{k.split("&")[0]}, #{h[k]} occurences" if h[k] > 1
  end
end
