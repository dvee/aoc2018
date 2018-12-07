require 'date'

class Event
  include Comparable

  attr_reader :date, :minute, :action

  def initialize(s)
    date, time, action = s.match(/^\[(.+) (.+)\] (.+)$/).captures
    hour, minute = time.split(":").map(&:to_i)

    @date =  hour == 23 ? Date.parse(date) + 1 : Date.parse(date)
    @minute = hour == 23 ? 0 : minute
    @action = action
  end

  def <=>(other)
    if (date <=> other.date) == 0
      minute <=> other.minute
    else
      date <=> other.date
    end
  end

  def to_s
    "#{@date} #{@minute} #{@action}"
  end
end

events = File.read('input4.txt').split("\n").map{ |s| Event.new(s) }
events.sort!

class NightlyLog
  attr_accessor :log, :guard
  def initialize(guard: nil)
    @log = Array.new(60){ 0 }
    @guard = guard
  end

  def apply_event(event)
    case event.action
    when /Guard #(\d+) begins shift/
      @guard = $1.to_i
    when /wakes up/
      (event.minute...60).each { |i| @log[i] = 0 }
    when /falls asleep/
      (event.minute...60).each { |i| @log[i] = 1 }
    end
  end
end

logs_by_date = Hash.new { |h,k| h[k] = NightlyLog.new }

events.each { |e| logs_by_date[e.date.to_s].apply_event(e) }

logs_by_guard = Hash.new { |h,k| h[k] = Array.new(60){ 0 } }

logs_by_date.each do |date, nightly_log|
  nightly_log.log.each_with_index do |v,i|
    logs_by_guard[nightly_log.guard][i] += v
  end
end

guard, log = logs_by_guard.max_by { |guard, log| log.sum }

most_slept_minute = log.each_with_index.max[1]

puts guard * most_slept_minute

#part 2

guard, log = logs_by_guard.max_by { |guard, log| log.max }

most_slept_minute = log.each_with_index.max[1]

puts guard * most_slept_minute
