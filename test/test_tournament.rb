require 'minitest_helper'

describe Connect4::Tournament do

  include Fixtures

  it 'is playable' do
    smartie = GoodPlayer.new
    dumby = BadPlayer.new
    tournament = Connect4::Tournament.new(smartie, dumby, games_per_match: 3)
    tournament.play
    tournament.winner.must_equal smartie
  end

end
