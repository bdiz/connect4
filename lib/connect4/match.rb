require 'connect4/game'

module Connect4

  class Match

    include Display

    DEFAULT_VERBOSITY = false
    DEFAULT_NUMBER_OF_GAMES = 1000
    DEFAULT_NUMBER_OF_GAMES_TO_DISPLAY = 5
    TIME_BETWEEN_DISPLAYS = 2

    attr_reader :winner

    def initialize player1, player2, options={}
      raise ArgumentError, "Player instances are same." if player1.object_id == player2.object_id
      @options = options
      @verbose = @options[:verbose] || DEFAULT_VERBOSITY
      @number_of_games = @options[:number_of_games] || DEFAULT_NUMBER_OF_GAMES
      @number_of_games_to_display = Integer(@options[:number_of_games_to_display] || DEFAULT_NUMBER_OF_GAMES_TO_DISPLAY)
      @player1, @player2 = player1, player2
      @player1.disk.symbol = @player2.disk.symbol = nil
      @winner = nil
      @wins = { @player1 => 0, @player2 => 0 }
      @draw = false
      @time_between_displays = TIME_BETWEEN_DISPLAYS
    end

    def play
      display self if @verbose
      who_plays_first = [@player1, @player2]
      @number_of_games.times do |game_number|
        silent_play = game_number >= @number_of_games_to_display
        game = Game.new(*who_plays_first, @options.merge(verbose: !silent_play && @verbose))
        game.scoreboard = scoreboard
        game.play
        @wins[game.winner] += 1
        game.scoreboard = scoreboard
        display(game, delay: 0.04) if silent_play and @verbose
        who_plays_first.rotate!
      end
      determine_winner
    end

    def draw?
      @draw
    end

    def scoreboard
      [@player1, @player2].sort_by {|p| p.disk.symbol }.reverse.map do |player|
        "#{player.disk.symbol} #{player} (#{@wins[player]} #{@wins[player] == 1 ? 'win' : 'wins'})"
      end
      .join("\n")
    end

    def to_s
      "#{@player1} vs #{@player2}"
    end

    private

    def determine_winner
      @winner =
        if @wins[@player1] == @wins[@player2]
          @draw = true 
          [@player1, @player2].sample
        else
          @wins.max_by {|player, wins| wins }.first
        end
    end

  end
end
