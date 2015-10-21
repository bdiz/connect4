require 'minitest_helper'

describe Connect4::Game do

  include Fixtures

  class Connect4::Player
    def keep_score
      Connect4::Tournament::Match::ScoreKeepingPlayer.new(self)
    end
  end

  it 'is playable' do
    game = Connect4::Game.new(good_player = GoodPlayer.new.keep_score, BadPlayer.new.keep_score)
    game.play
    game.winner.must_equal good_player
  end

  it 'knows when there is a winner' do
    ['vertical', 'horizontal', 'rising_diagonal', 'falling_diagonal'].each do |ways_to_win|
      fixtures[ways_to_win].each do |scenario|
        p1 = PredictablePlayer.new(scenario['next_move']).keep_score
        p2 = Player2.new.keep_score
        stub_grid(scenario['grid'], p1, p2) do
          game = Connect4::Game.new(p1, p2)
          game.play
          game.winner.must_equal p1
          game.draw?.must_equal false
        end
      end
    end
  end

  it 'knows when the game is a draw' do
    fixtures['draw'].each do |scenario|
      p1 = PredictablePlayer.new(scenario['next_move']).keep_score
      p2 = Player2.new.keep_score
      stub_grid(scenario['grid'], p1, p2) do
        game = Connect4::Game.new(p1, p2)
        game.play
        game.winner.must_equal nil
        game.draw?.must_equal true
      end
    end
  end

  it 'forces a player to lose if they overflow a column' do
    fixtures['column_overflow'].each do |scenario|
      p1 = PredictablePlayer.new(scenario['next_move']).keep_score
      p2 = Player2.new.keep_score
      stub_grid(scenario['grid'], p1, p2) do
        game = Connect4::Game.new(p1, p2)
        game.column_overflowed?.must_equal false
        game.play
        game.column_overflowed?.must_equal true
        game.winner.must_equal p2
      end
    end
  end

  it 'forces a player to lose if they do not choose a valid column' do
    game = Connect4::Game.new(InvalidColumnPlayer.new.keep_score, player2 = Player2.new.keep_score)
    game.invalid_column_played?.must_equal false
    game.play
    game.invalid_column_played?.must_equal true
    game.winner.must_equal player2
  end

  it 'forces a player to lose if they cause an exception' do
    game = Connect4::Game.new(ExceptionalPlayer.new.keep_score, player2 = Player2.new.keep_score)
    game.player_crashed?.must_equal false
    game.play
    game.player_crashed?.must_equal true
    game.winner.must_equal player2
  end

  it 'forces a player to lose if they do not move fast enough' do
    game = Connect4::Game.new(SlowPlayer.new.keep_score, player2 = Player2.new.keep_score)
    game.player_timeout?.must_equal false
    game.play
    game.player_timeout?.must_equal true
    game.winner.must_equal player2
  end

end
