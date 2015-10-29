require 'connect4/round'

module Connect4
  class Tournament

    include Display

    DEFAULT_VERBOSITY = false
    TIME_BETWEEN_DISPLAYS = 0

    attr_reader :winner

    def initialize *players
      @options = (players.last.is_a?(Hash) ? players.pop : {}).delete_if {|k,v| v.nil? }
      raise ArgumentError, "Not enough players: #{players.map(&:name)}" if players.length < 2
      @verbose = @options.fetch(:verbose, DEFAULT_VERBOSITY)
      @round_number = 0
      @round = Round.new(players.shuffle, @options)
      @time_between_displays = TIME_BETWEEN_DISPLAYS
    end

    def play
      display_round
      @round.play
      while @round.winners.length > 1
        @round = Round.new(@round.winners, @options)
        display_round
        @round.play
      end
      @winner = @round.winners.first
      display_champion
    end

    private

    def display_round
      display "ROUND: #{@round_number += 1}\n" if @verbose
    end

    def display_champion
      if @verbose
        display "\nLadies and gentlemen, your new champion... #{@winner.name.upcase}!!!\n", clear: false
        sleep 5
      end
    end

  end
end
