$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'connect4'

require 'minitest/spec'
require 'minitest/autorun'

require 'json'

module Fixtures

  FIXTURES_DIR =  File.expand_path('../fixtures', __FILE__)
  FIXTURE_JSON_FILES = Dir.glob(File.join(FIXTURES_DIR, '**/*.json'))
  FIXTURE_RUBY_FILES = Dir.glob(File.join(FIXTURES_DIR, '**/*.rb'))

  class << self

    def included base
      load_fixtures
    end

    attr_reader :fixtures

    def load_fixtures
      @fixtures ||= begin
        FIXTURE_RUBY_FILES.each {|file| load file }
        FIXTURE_JSON_FILES.each_with_object({}) do |file, fixtures|
          fixtures.merge!(JSON.load(File.read(file)))
        end
      end
    end

  end

  def fixtures
    Fixtures.fixtures
  end

  def stub_board board_fixture, player1, player2, &block
    board = Connect4::Board.from_array(board_fixture, player1, player2)
    Connect4::Board.stub(:new, board) do
      block.call
    end
  end

end

