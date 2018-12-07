s = File.read('input5.txt').strip

def reacts?(x, y)
  x.downcase == y.downcase && x != y
end

def react!(s)
  i = 0
  while i < s.length - 1
    if reacts?(s[i], s[i+1])
      s.slice!(i..(i+1))
      i = [i - 1, 0].max
    else
      i += 1
    end
  end
  return s
end

puts react!(s).length

#part 2

s = File.read('input5.txt').strip

unit_types = s.downcase.chars.uniq

h = Hash.new

unit_types.each do |u|
  x = s.dup
  x.tr!(u, '')
  x.tr!(u.upcase, '')
  h[u] = react!(x)
end

unit_to_remove, resulting_polymer = h.min_by{ |u,s| s.length }

puts resulting_polymer.length
