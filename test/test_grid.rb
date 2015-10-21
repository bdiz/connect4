require 'minitest_helper'

describe Connect4::Grid do

  include Fixtures

  let(:player1) { Player1.new }
  let(:player2) { Player2.new }

  it 'detects vertical consecutive disks' do
    fixtures['vertical'].each do |scenario|
      grid = set_up_grid(scenario['grid'], player1, player2)

      grid.consecutive_vertical_disks.empty?.must_equal true
      grid.consecutive_horizontal_disks.empty?.must_equal true
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal true
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal true
      grid.has_consecutive_disks?.must_equal false

      grid.insert(player1.disk, scenario['next_move'])

      grid.consecutive_vertical_disks.empty?.must_equal false
      grid.consecutive_horizontal_disks.empty?.must_equal true
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal true
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal true
      grid.has_consecutive_disks?.must_equal true
    end
  end

  it 'detects horizontal consecutive disks' do
    fixtures['horizontal'].each do |scenario|
      grid = set_up_grid(scenario['grid'], player1, player2)

      grid.consecutive_vertical_disks.empty?.must_equal true
      grid.consecutive_horizontal_disks.empty?.must_equal true
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal true
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal true
      grid.has_consecutive_disks?.must_equal false

      grid.insert(player1.disk, scenario['next_move'])

      grid.consecutive_vertical_disks.empty?.must_equal true
      grid.consecutive_horizontal_disks.empty?.must_equal false
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal true
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal true
      grid.has_consecutive_disks?.must_equal true
    end
  end

  it 'detects a falling diagonal win' do
    fixtures['falling_diagonal'].each do |scenario|
      grid = set_up_grid(scenario['grid'], player1, player2)

      grid.consecutive_vertical_disks.empty?.must_equal true
      grid.consecutive_horizontal_disks.empty?.must_equal true
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal true
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal true
      grid.has_consecutive_disks?.must_equal false

      grid.insert(player1.disk, scenario['next_move'])

      grid.consecutive_vertical_disks.empty?.must_equal true
      grid.consecutive_horizontal_disks.empty?.must_equal true
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal false
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal true
      grid.has_consecutive_disks?.must_equal true
    end
  end

  it 'detects a rising diagonal win' do
    fixtures['rising_diagonal'].each do |scenario|
      grid = set_up_grid(scenario['grid'], player1, player2)

      grid.consecutive_vertical_disks.empty?.must_equal true
      grid.consecutive_horizontal_disks.empty?.must_equal true
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal true
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal true
      grid.has_consecutive_disks?.must_equal false

      grid.insert(player1.disk, scenario['next_move'])

      grid.consecutive_vertical_disks.empty?.must_equal true
      grid.consecutive_horizontal_disks.empty?.must_equal true
      grid.consecutive_diagonal_disks(:falling).empty?.must_equal true
      grid.consecutive_diagonal_disks(:rising).empty?.must_equal false
      grid.has_consecutive_disks?.must_equal true
    end
  end

  it 'detects when the grid is filled' do
    fixtures['draw'].each do |scenario|
      grid = set_up_grid(scenario['grid'], player1, player2)
      grid.full?.must_equal false
      grid.insert(player1.disk, scenario['next_move'])
      grid.full?.must_equal true
    end
  end

  it 'detects when a full column is played' do
    fixtures['column_overflow'].each do |scenario|
      grid = set_up_grid(scenario['grid'], player1, player2)
      lambda {
        grid.insert(player1.disk, scenario['next_move'])
      }.must_raise(Connect4::Column::OverflowError)
    end
  end

end
