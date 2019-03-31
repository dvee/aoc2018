# part 2 in reasonable time:
# https://www.reddit.com/r/adventofcode/comments/a86jgt/2018_day_21_solutions/ec8fsc5?utm_source=share&utm_medium=web2x

require 'set'
seen = Set.new

def f a;
    a |= 0x10000
    b = 1099159
    b += a&0xff;       b &= 0xffffff
    b *= 65899;        b &= 0xffffff
    b += (a>>8)&0xff;  b &= 0xffffff
    b *= 65899;        b &= 0xffffff
    b += (a>>16)&0xff; b &= 0xffffff
    b *= 65899;        b &= 0xffffff
    b
end

n = f 0
loop {
    n2 = f n
    abort "#{n}" if seen.include? n2
    seen.add n
    n = n2
}
