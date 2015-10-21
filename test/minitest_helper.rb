$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'connect4'

require 'minitest/spec'
require 'minitest/autorun'

require 'yaml'

module Fixtures

  FIXTURES_DIR =  File.expand_path('../fixtures', __FILE__)
  FIXTURE_YAML_FILES = Dir.glob(File.join(FIXTURES_DIR, '**/*.{yaml,yml}'))
  FIXTURE_RUBY_FILES = Dir.glob(File.join(FIXTURES_DIR, '**/*.rb'))

  class << self

    def included base
      load_fixtures
    end

    attr_reader :fixtures

    def load_fixtures
      @fixtures ||= begin
        FIXTURE_RUBY_FILES.each {|file| load file }
        FIXTURE_YAML_FILES.each_with_object({}) do |file, fixtures|
          fixtures.merge!(YAML.load(File.read(file)))
        end
      end
    end

  end

  def fixtures
    Fixtures.fixtures
  end

  def set_up_grid(grid_fixture, player1, player2)
    Connect4::Grid.new.tap do |grid|
      rows = String(grid_fixture).split("\n")
      rows = rows.map {|row| row.split }
      columns = rows.transpose.map {|c| c.reverse }
      columns.each_with_index do |column, column_index|
        column.each do |char|
          if char == 'x'
            grid.insert(player1.disk, column_index)
          elsif char == '-'
            grid.insert(player2.disk, column_index)
          end
        end
      end
    end
  end

  def stub_grid grid_fixture, player1, player2, &block
    grids = [
      set_up_grid(grid_fixture, player1, player2),
      set_up_grid(grid_fixture, player1, player2),
      set_up_grid(grid_fixture, player1, player2)
    ]
    Connect4::Grid.stub(:new, -> { grids.pop }) do
      block.call
    end
  end

end

