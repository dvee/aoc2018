require 'pry'

steps = File.read('input7_test.txt').split("\n")
steps = steps.map{ |s| s.match(/Step (\w) must be finished before step (\w) can begin\./).captures }

steps_hash = Hash.new{ |h,k| h[k] = Array.new }
#initialize
steps.each { |dependent, step|
  steps_hash[step] = []
  steps_hash[dependent] = []
}
#populate depdendencies
steps.each { |dependent, step| steps_hash[step] << dependent }

steps_hash

def next_step(steps_hash)
  steps_hash.select{ |k,v| v.empty? }.sort_by{ |k,v| k }[0][0]
end

def complete_step(steps_hash, step)
  steps_hash.each { |k,v| v.delete(step) }
  steps_hash.delete(step)
end

steps_log = ""
while !steps_hash.empty?
  step = next_step(steps_hash)
  steps_log << step
  puts steps_log
  complete_step(steps_hash, step)
end


#part 2

STEP_BASE_TIME = 60
N_WORKERS = 5
INPUT_FILE = 'input7.txt'

class Step
  attr_reader :label

  def initialize(letter:)
    @step_time = letter.ord - "A".ord + 1 + STEP_BASE_TIME
    @label = letter
    @dependents = []
  end

  def add_dependent(c)
    @dependents << c
  end

  def remove_dependent(c)
    @dependents.delete(c)
  end

  def ready?
    @dependents.empty?
  end

  def tick
    return @step_time -= 1
  end

  def ==(other)
    label == other.label
  end
end

class Worker
  attr_accessor :current_task
  def initialize
    @current_task = nil
  end

  def set_task(c)
    self.current_task = c
  end

  def finish_task
    self.current_task = nil
  end

  def idle?
    current_task.nil?
  end
end

class Solver
  def initialize
    n_workers = N_WORKERS
    steps = File.read(INPUT_FILE).split("\n")
    steps = steps.map{ |s| s.match(/Step (\w) must be finished before step (\w) can begin\./).captures }
    steps_hash = Hash.new
    steps.each { |dependent, step|
      steps_hash[step] = Step.new(letter: step)
      steps_hash[dependent] = Step.new(letter: dependent)
    }
    #populate depdendencies
    steps.each { |dependent, step| steps_hash[step].add_dependent(dependent) }
    @steps = steps_hash.map{ |k,v| v }
    @workers = Array.new(n_workers){ Worker.new }
    @t=0
    @wip_tasks = []
    @done_tasks = []
  end

  def solve
    while !@steps.empty?
      assign_tasks
      print_state
      tick
    end
    print_state #one off print for last step
  end

  def assign_tasks
    @workers.select{ |w| w.idle? }.each do |w|
      if s = next_step_ready
        w.set_task(s.label)
        @wip_tasks << s.label
      end
    end
  end

  def next_step_ready
    @steps.select{ |step| step.ready? && !@wip_tasks.include?(step.label) }&.sort_by{ |s| s.label }&.first
  end

  def tick
    @workers.select{ |w| !w.idle? }.each do |w|
      step = @steps.find{ |s| s.label == w.current_task }
      time_left = step.tick
      if time_left == 0
        w.finish_task
        @steps.each{ |s| s.remove_dependent(step.label)}
        @wip_tasks.delete(step.label)
        @done_tasks << step.label
        @steps.delete(step)
      end
    end
    @t += 1
  end

  def print_state
    puts "#{@t}\t" + @workers.map{ |w| w.current_task || '.' }.join("\t") + "\t#{@done_tasks.join('')}"
  end
end

Solver.new.solve
