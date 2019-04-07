require 'spec_helper'
require 'pry'

require_relative '../day15'

test1_targets = <<-'DATA'
#######
#E..G.#
#...#.#
#.G.#G#
#######
DATA

test1_in_range = <<-'DATA'
#######
#E.?G?#
#.?.#?#
#?G?#G#
#######
DATA

test1_reachable = <<-'DATA'
#######
#E.@G.#
#.@.#.#
#@G@#G#
#######
DATA

test1_nearest = <<-'DATA'
#######
#E.!G.#
#.!.#.#
#!G.#G#
#######
DATA

test1_chosen = <<-'DATA'
#######
#E.+G.#
#...#.#
#.G.#G#
#######
DATA

graph_1_edges = [[1,2], [1,3], [2,3], [2,4], [3,4], [4,5]]
#   2
#  /|\
# 1 | 4 - 5
#  \|/
#   3

test2_map = <<-'DATA'
#######
#.E...#
#.....#
#...G.#
#######
DATA

test2_move = <<-'DATA'
#######
#..E..#
#.....#
#...G.#
#######
DATA

test3_move_in = <<-'DATA'
#########
#G..G..G#
#.......#
#.......#
#G..E..G#
#.......#
#.......#
#G..G..G#
#########
DATA

test3_move_out_1 = <<-'DATA'
#########
#.G...G.#
#...G...#
#...E..G#
#.G.....#
#.......#
#G..G..G#
#.......#
#########
DATA

test3_move_out_2 = <<-'DATA'
#########
#..G.G..#
#...G...#
#.G.E.G.#
#.......#
#G..G..G#
#.......#
#.......#
#########
DATA



test3_move_out_3 = <<-'DATA'
#########
#.......#
#..GGG..#
#..GEG..#
#G..G...#
#......G#
#.......#
#.......#
#########
DATA

test_battle_1 = <<-'DATA'
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
DATA

my_input = <<-'DATA'
################################
#######..G######################
########.....###################
##########....############.....#
###########...#####..#####.....#
###########G..###GG....G.......#
##########.G#####G...#######..##
###########...G.#...############
#####.#####..........####....###
####.....###.........##.#....###
####.#................G....#####
####......#.................####
##....#G......#####........#####
########....G#######.......#####
########..G.#########.E...######
########....#########.....######
#######.....#########.....######
#######...G.#########....#######
#######...#.#########....#######
####.G.G.....#######...#.#######
##...#...G....#####E...#.#######
###..#.G.##...E....E.......###.#
######...................#....E#
#######...............E.########
#G###...#######....E...#########
#..##.######.E#.#.....##########
#..#....##......##.E...#########
#G......###.#..##......#########
#....#######....G....E.#########
#.##########..........##########
#############.###.......########
################################
DATA

describe "Problem 15" do
  let(:test1_map) { Map.new(test1_targets) }

  describe Map do
    describe ".new" do
      it "should initialize @units" do
        expect(test1_map.units.size).to eq 4
      end
    end

    describe "#to_s" do
      it "should output the map in aoc format" do
        expect(test1_map.to_s).to eq test1_targets
      end
    end
  end

  describe Unit do
    let(:test1_unit) { test1_map.units.first }
    describe "#open_neighbouring_squares" do
      it "should correctly identify targets in range" do
        target_coords = test1_unit.open_target_squares
        expect(test1_map.to_s_with_overlay('?', target_coords)).to eq test1_in_range
      end
    end

    describe "#reachable_target_squares" do
      it "should correctly identify reachable target squares" do
        expect(test1_map.to_s_with_overlay('@', test1_unit.reachable_target_squares)).to eq test1_reachable
      end

      # #18,5
      # it "finds reachable squares for my challenge input" do
      #   map = Map.new(my_input)
      #   unit = map.units.find{ |u| u.current_position == [18, 5] }
      #   expect(unit.reachable_target_squares).not_to be_empty
      # end
    end

    describe "#nearest squares" do
      it "should correctly identify the nearest square(s)" do
        expect(test1_map.to_s_with_overlay('!', test1_unit.nearest_squares)).to eq test1_nearest
      end
    end

    describe "#choose_target_square" do
      it "should pick the nearest square in reading order if there is a tie" do
        expect(test1_map.to_s_with_overlay('+', [test1_unit.choose_target_square])).to eq test1_chosen
      end
    end

    let(:test2) { Map.new(test2_map) }
    let(:test2_unit) { test2.units.first }

    describe "#choose_step" do
      it "picks the next step by reading in order in a tie" do
        expect(test2_unit.choose_step(test2_unit.choose_target_square)).to eq [3 ,1]
      end
    end

    describe "#move" do
      it "updates the map" do
        test2_unit.move([3, 1])
        expect(test2_unit.map.to_s).to eq test2_move
      end
    end
  end

  describe Battle do
    describe "#phase" do
      it "moves units correctly" do
        battle = Battle.new(test3_move_in)
        expect(battle.map.to_s).to eq test3_move_in
        results = [test3_move_out_1, test3_move_out_2, test3_move_out_3]
        results.each do |r|
          battle.phase
          expect(battle.map.to_s).to eq r
        end
      end
    end

    describe "#run" do
      it "gives the correct outcome" do
        b = Battle.new(test_battle_1)
        expect(b.run).to eq 27730
      end
    end
  end
end
