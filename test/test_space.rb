require 'minitest_helper'

describe Connect4::Space do

  include Fixtures

  let(:player1) { Player1.new }
  let(:player2) { Player2.new }

  it 'detects vertical consecutive disks' do
    fixtures['vertical'].each do |scenario|
      board = Connect4::Board.from_array(scenario['board'], player1, player2)
      board.insert(player1.disk, scenario['next_move'])

      space = board.last_space_played
      space.part_of_vertical?.must_equal true
      space.part_of_horizontal?.must_equal false
      space.part_of_falling_diagonal?.must_equal false
      space.part_of_rising_diagonal?.must_equal false
      space.part_of_consecutive?.must_equal true
    end
  end

  it 'detects horizontal consecutive disks' do
    fixtures['horizontal'].each do |scenario|
      board = Connect4::Board.from_array(scenario['board'], player1, player2)
      board.insert(player1.disk, scenario['next_move'])

      space = board.last_space_played
      space.part_of_vertical?.must_equal false
      space.part_of_horizontal?.must_equal true
      space.part_of_falling_diagonal?.must_equal false
      space.part_of_rising_diagonal?.must_equal false
      space.part_of_consecutive?.must_equal true
    end
  end

  it 'detects a falling diagonal win' do
    fixtures['falling_diagonal'].each do |scenario|
      board = Connect4::Board.from_array(scenario['board'], player1, player2)
      board.insert(player1.disk, scenario['next_move'])

      space = board.last_space_played
      space.part_of_vertical?.must_equal false
      space.part_of_horizontal?.must_equal false
      space.part_of_falling_diagonal?.must_equal true
      space.part_of_rising_diagonal?.must_equal false
      space.part_of_consecutive?.must_equal true
    end
  end

  it 'detects a rising diagonal win' do
    fixtures['rising_diagonal'].each do |scenario|
      board = Connect4::Board.from_array(scenario['board'], player1, player2)
      board.insert(player1.disk, scenario['next_move'])

      space = board.last_space_played
      space.part_of_vertical?.must_equal false
      space.part_of_horizontal?.must_equal false
      space.part_of_falling_diagonal?.must_equal false
      space.part_of_rising_diagonal?.must_equal true
      space.part_of_consecutive?.must_equal true
    end
  end
end
