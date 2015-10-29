require 'connect4/match'

module Connect4
  class Round

    include Display

    TIME_BETWEEN_DISPLAYS = 7

    def initialize players, options={}
      @options = options.delete_if {|k,v| v.nil? }
      @verbose = @options[:verbose]
      @games_per_match = @options[:games_per_match]
      @players = players
      @winners = []
      @time_between_displays = TIME_BETWEEN_DISPLAYS
    end

    def play
      display_matches
      matches.each do |match|
        match.play
        @winners << match.winner
        display_match_winner match
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
              matches << Match.new(player1, player2, @options)
            end
          end
        end
    end

    def display_matches
      if @verbose
        if matches and @bye
          display("#{self}\n\n  #{@bye} gets a bye this round.", clear: false)
        else
          display(self, clear: false)
        end
      end
    end

    def display_match_winner match
      display("\n#{match.winner} wins the match#{match.draw? ? " via a random draw." : '!'}", clear: false) if @verbose
    end

  end
end
