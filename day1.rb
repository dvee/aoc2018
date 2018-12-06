puts File.read('input1.txt').split("\n").map(&:to_i).reduce(:+)

require 'set'

f_log = Set.new([0])
m = 0
File.read('input1.txt').split("\n").map(&:to_i).cycle do |f|
  m += f
  if f_log.include?(m)
      puts "dup freq found! #{m}"
      break
  end
  f_log.add(m)
end
