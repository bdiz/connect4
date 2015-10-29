require 'connect4/version'
require 'connect4/tournament'
require 'connect4/player'

module Connect4
  class Player
    class << self
      def inherited sub
        @players ||= []
        @players << sub
      end

      def players
        @players ? @players.map(&:new) : []
      end
    end
  end
end

players_dir = File.expand_path("../connect4/players", __FILE__)
Dir.glob("#{players_dir}/*.rb").each {|file| load file }
