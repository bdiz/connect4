require 'connect4/game'
require 'delegate'

module Connect4
  class Tournament

    include Display

    DEFAULT_VERBOSITY = true

    attr_reader :winner

    def initialize *players
      options = (players.last.is_a?(Hash) ? players.pop : {}).delete_if {|k,v| v.nil? }
      raise ArgumentError, "Not enough players: #{players.map(&:name)}" if players.length < 2
      @verbose = options.fetch(:verbose, DEFAULT_VERBOSITY)
      @round_number = 0
      @round_options = {
        verbose:            @verbose,
        games_per_match:    options[:games_per_match]
      }
      @round = Round.new(players.shuffle, @round_options)
      @time_between_displays = 0
    end

    def play
      display "ROUND: #{@round_number += 1}\n" if @verbose
      @round.play
      while @round.winners.length > 1
        @round = Round.new(@round.winners, @round_options)
        display "ROUND: #{@round_number += 1}\n" if @verbose
        @round.play
      end
      @winner = @round.winners.first
      if @verbose
        display "\nLadies and gentlemen, your new champion... #{@winner.name.upcase}!!!\n", clear: false
        sleep 5
      end
    end

    class Round

      include Display

      TIME_BETWEEN_DISPLAYS = 7

      def initialize players, options={}
        options = options.delete_if {|k,v| v.nil? }
        @verbose = options[:verbose]
        @games_per_match = options[:games_per_match]
        @players = players
        @winners = []
        @time_between_displays = TIME_BETWEEN_DISPLAYS
      end

      def play
        if @verbose
          if matches and @bye
            display("#{self}\n\n  #{@bye} gets a bye this round.", clear: false)
          else
            display(self, clear: false)
          end
        end
        matches.each do |match|
          match.play
          @winners << match.winner
          display("\n#{match.winner} wins the match#{match.draw? ? " via a random draw." : '!'}", clear: false) if @verbose
        end
      end

      def winners
        @bye ?  ([@bye] + @winners) : @winners
      end

      def to_s
        "  #{matches.map(&:to_s).join("\n  ")}"
      end

      private

      def matches
        @matches ||= 
          [].tap do |matches|
            @players.each_slice(2) do |player1, player2|
              if player2.nil?
                @bye = player1
              else
                matches << Match.new(player1, player2, number_of_games: @games_per_match, verbose: @verbose)
              end
            end
          end
      end

    end

    class Match

      class ScoreKeepingPlayer < SimpleDelegator

        attr_reader :wins

        def initialize player
          super(player)
          @wins = 0
        end

        def add_win
          @wins += 1
        end

      end

      include Display

      DEFAULT_NUMBER_OF_GAMES = 1000
      NUMBER_OF_GAMES_TO_DISPLAY = 5
      TIME_BETWEEN_DISPLAYS = 2

      attr_reader :winner

      def initialize player1, player2, options={}
        raise ArgumentError, "Player instances are same." if player1.object_id == player2.object_id
        @verbose = options[:verbose] || false
        @number_of_games = options[:number_of_games] || DEFAULT_NUMBER_OF_GAMES
        @player1, @player2 = ScoreKeepingPlayer.new(player1), ScoreKeepingPlayer.new(player2)
        @player1.disk.symbol = @player2.disk.symbol = nil
        @winner = nil
        @draw = false
        @time_between_displays = TIME_BETWEEN_DISPLAYS
      end

      def play
        display self if @verbose
        who_plays_first = [@player1, @player2]
        @number_of_games.times do |game_number|
          silent_play = game_number >= Integer(ENV.fetch('GAMES_TO_DISPLAY', NUMBER_OF_GAMES_TO_DISPLAY))
          game = Game.new(*who_plays_first, verbose: !silent_play && @verbose)
          game.play
          display(game, delay: 0.07) if silent_play and @verbose
          who_plays_first.rotate!
        end
        determine_winner
      end

      def draw?
        @draw
      end

      def to_s
        "#{@player1} vs #{@player2}"
      end

      private

      def determine_winner
        @winner =
          if @player1.wins == @player2.wins
            @draw = true 
            [@player1, @player2].sample
          else
            [@player1, @player2].max_by(&:wins)
          end
      end

    end

  end
end
