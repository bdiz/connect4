require 'minitest_helper'

describe Connect4::Board do

  include Fixtures

  let(:player1) { Player1.new }
  let(:player2) { Player2.new }

  it 'detects when the board is filled' do
    fixtures['draw'].each do |scenario|
      board = Connect4::Board.from_array(scenario['board'], player1, player2)
      board.full?.must_equal false
      board.insert(player1.disk, scenario['next_move'])
      board.full?.must_equal true
    end
  end

  it 'detects when a full column is played' do
    fixtures['column_overflow'].each do |scenario|
      board = Connect4::Board.from_array(scenario['board'], player1, player2)
      lambda {
        board.insert(player1.disk, scenario['next_move'])
      }.must_raise(Connect4::Board::ColumnOverflowError)
    end
  end

  it 'can remove disks' do
    fixtures['remove_disk'].each do |scenario|
      board = Connect4::Board.from_array(scenario['board'], player1, player2)
      first_empty_slot = Connect4::Board::NUMBER_OF_ROWS
      Connect4::Board::NUMBER_OF_ROWS.times do
        board.remove(scenario['next_move'])
        first_empty_slot -= 1
        board[scenario['next_move']].each_with_index do |space, index|
          if index >= first_empty_slot
            space.empty?.must_equal true
          else
            space.empty?.must_equal false
          end
        end
      end
      lambda {
        board.remove(scenario['next_move'])
      }.must_raise(Connect4::Space::UnderflowError)
    end
  end

  it 'can set a save point and revert back to that point' do
    fixtures['savepoint'].each do |scenario|
      board1 = Connect4::Board.from_array(scenario['board'], player1, player2)
      board2 = Connect4::Board.from_array(scenario['board'], player1, player2)
      board2.must_equal board1
      board2.set_savepoint
      3.times { board2.insert(player1.disk, rand(0..Connect4::Board::NUMBER_OF_COLUMNS-1)) }
      board2.wont_equal board1
      2.times { board2.remove(rand(0..Connect4::Board::NUMBER_OF_COLUMNS-1)) }
      board2.wont_equal board1
      board2.restore_savepoint
      board2.must_equal board1
    end
  end

end
