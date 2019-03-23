require 'set'

class Group
  attr_accessor :targeted_by, :target, :army
  attr_reader :initiative, :immunities, :weaknesses, :number_of_units
  def initialize(number_of_units:, hit_points:, attack_damage:, attack_type:, initiative:, weaknesses:, immunities:, boost: 0)
    @number_of_units = number_of_units.to_i
    @hit_points_per_unit = hit_points.to_i
    @attack_damage = attack_damage.to_i + boost.to_i
    @attack_type = attack_type
    @initiative = initiative.to_i
    @weaknesses = weaknesses
    @immunities = immunities
    @target = nil
    @targeted_by = nil
  end

  def self.from_string(s, boost: 0)
    number_of_units, hit_points, _, weak_immune_s, attack_damage, attack_type, initiative = s.match(/(\d+) units each with (\d+) hit points (\((.*)\) )?with an attack that does (\d+) (\w+) damage at initiative (\d+)/).captures
    weaknesses, immunities = parse_weakness_immunity(weak_immune_s)
    self.new(
      number_of_units: number_of_units,
      hit_points: hit_points,
      attack_damage: attack_damage,
      attack_type: attack_type,
      initiative: initiative,
      weaknesses: weaknesses,
      immunities: immunities,
      boost: boost
      )
  end

  def effective_power
    @number_of_units * @attack_damage
  end

  def select_target(potential_targets)
    @target = potential_targets.sort do |a,b|
      if potential_damage(a) == potential_damage(b)
        if a.effective_power == b.effective_power
          a.initiative <=> b.initiative
        else
          a.effective_power <=> b.effective_power
        end
      else
        potential_damage(a) <=> potential_damage(b)
      end
    end.last
    @target = nil if @target && potential_damage(@target) == 0
    @target.targeted_by = self if @target
  end

  def potential_damage(target)
    multiplier = begin
      if target.immunities.include?(@attack_type)
        0
      elsif target.weaknesses.include?(@attack_type)
        2
      else
        1
      end
    end
    return multiplier * effective_power
  end

  def attack(target)
    units_killed = target.receives_damage!(potential_damage(target))
    #puts "#{army.name} #{self} attacks #{target.army.name} #{target}, killing #{units_killed} units"
  end

  def receives_damage!(damage)
    previous_number_if_units = @number_of_units
    @number_of_units -= damage / @hit_points_per_unit
    @number_of_units = 0 if @number_of_units < 0
    return previous_number_if_units - number_of_units
  end

  def target_reset
    @target = nil
    @targeted_by = nil
  end

  private

  def self.parse_weakness_immunity(s)
    weaknesses = []
    immunities = []
    s.split('; ').each do |ss|
      weak_or_immune, attacks_s = ss.match(/(\w+) to (.+)/).captures
      case weak_or_immune
      when "weak"
        weaknesses = attacks_s.split(", ")
      when "immune"
        immunities = attacks_s.split(", ")
      end
    end unless s.nil?
    return [weaknesses, immunities]
  end
end

class Army
  attr_accessor :groups
  attr_reader :name
  def initialize(name, groups, boost: 0)
    @groups = groups
    @name = name

    @groups.each { |g| g.army = self }
  end

  def self.from_string(name, s, boost: 0)

    #puts s.split("\n")
    groups = s.split("\n").map{ |ss| Group.from_string(ss, boost: boost) }
    self.new(name, groups)
  end
end

f = File.read('input24.txt')
immune_s, infection_s = f.match(/Immune System:\n(.*)\nInfection:\n(.*)/m).captures
immune = Army.from_string(:immune, immune_s)
infection = Army.from_string(:infection, infection_s)

boost = 50
last_win = :immune
while last_win == :immune
immune = Army.from_string(:immune, immune_s, boost: boost)
infection = Army.from_string(:infection, infection_s)
  loop do
    #target selection
    remaining_targets = Set.new(immune.groups + infection.groups)
    (immune.groups + infection.groups).sort do |a,b|
      if a.effective_power == b.effective_power
        a.initiative <=> b.initiative
      else
        a.effective_power <=> b.effective_power
      end
    end.reverse.each do |g|
      other_army = case g.army.name
      when :immune
        :infection
      when :infection
        :immune
      end
      g.select_target(remaining_targets.select { |g| g.army.name == other_army })
      remaining_targets.delete(g.target) if g.target
    end

    #attack phase
    (immune.groups + infection.groups).sort_by { |g| g.initiative }.reverse.each do |g|
      g.attack(g.target) if g.target
    end

    #clean up and reset
    immune.groups = immune.groups.select { |g| g.number_of_units > 0 }
    infection.groups = infection.groups.select { |g| g.number_of_units > 0 }
    (immune.groups + infection.groups).each(&:target_reset)

    if immune.groups.size == 0 || infection.groups.size == 0
      puts "boost: #{boost}, remaining units... immune: #{immune.groups.sum{ |g| g.number_of_units }}, infection: #{infection.groups.sum{ |g| g.number_of_units }}"
      if immune.groups.size == 0
        last_win = :infection
      elsif infection.groups.size == 0
        last_win = :immune
      end
      boost -= 1
      break
    end
  end
end
