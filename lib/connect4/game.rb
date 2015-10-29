require 'connect4/board'
require 'connect4/display'
require 'timeout'

module Connect4
  class Game

    include Display

    class PlayerTimeout < Timeout::Error
    end

    DEFAULT_VERBOSITY = false
    DEFAULT_TIME_ALLOWED_PER_MOVE = 0.25
    TIME_BETWEEN_DISPLAYS = 1.5
    PLAYER1_DISK_SYMBOL = Board::DISK_SYMBOL.colorize(color: :red)
    PLAYER2_DISK_SYMBOL = Board::DISK_SYMBOL.colorize(color: :black)

    attr_reader :winner, :special_circumstance

    def initialize player1, player2, options={}
      raise ArgumentError, "Player instances are same." if player1.object_id == player2.object_id

      @verbose = options[:verbose] || DEFAULT_VERBOSITY
      @time_between_displays = TIME_BETWEEN_DISPLAYS
      @time_allowed_per_move = Float(options[:time_allowed_per_move] || DEFAULT_TIME_ALLOWED_PER_MOVE)
      @debug = options[:debug]

      @player1, @player2 = player1, player2

      @player1.reset
      @player2.reset

      @player1.disk.symbol ||= PLAYER1_DISK_SYMBOL
      @player2.disk.symbol ||= PLAYER2_DISK_SYMBOL

      @board = Board.new
      @turn = [@player1, @player2]
      @winner = nil
      @draw = false

      @special_circumstance = nil
      @column_overflowed = false
      @player_timeout = false
      @invalid_column_played = false
      @player_crashed = false
    end

    def play
      display self if @verbose
      determine_winner do
        while !game_over?
          column = nil
          keep_time! do
            player = @turn.rotate!.last
            column = player.next_move(@board.to_a(player))
          end
          play_disk(column)
          display self if @verbose
        end
      end
      display_winner if @verbose
    end

    def draw?
      @draw
    end

    def column_overflowed?
      @column_overflowed
    end

    def invalid_column_played?
      @invalid_column_played
    end

    def player_crashed?
      @player_crashed
    end

    def player_timeout?
      @player_timeout
    end

    attr_accessor :scoreboard
    def to_s
      "#{scoreboard}\n\n#{@board}"
    end

    private

    def play_disk column
      @board.insert(@turn.last.disk, column)
    end

    def determine_winner &block
      block.call
      @winner = @turn.last unless draw?
    rescue Board::ColumnOverflowError => e
      @special_circumstance = "#{@turn.last} put a disk #{e.message} when it was full. #{@turn.first} wins."
      @column_overflowed = true
      @winner = @turn.first
    rescue PlayerTimeout => e
      @special_circumstance = "#{@turn.last} took too long to play - timeout. #{@turn.first} wins."
      @player_timeout = true
      @winner = @turn.first
    rescue Board::InvalidColumnPlayed => e
      @invalid_column_played = true
      @special_circumstance = "#{@turn.last} played into an invalid column, #{e.message.inspect}. #{@turn.first} wins."
      @winner = @turn.first
    rescue => e
      @player_crashed = true
      @special_circumstance = "#{@turn.last} crashed with a #{$!.class}. #{@turn.first} wins."
      @winner = @turn.first
    ensure
      raise e if e and @debug
    end

    def game_over?
      (@board.last_space_played && @board.last_space_played.part_of_consecutive?) || (@draw = @board.full?)
    end

    def keep_time! &block
      Timeout::timeout(@time_allowed_per_move, PlayerTimeout) { block.call }
    end

    def display_winner
      display(self)
      if special_circumstance
        display("\n#{special_circumstance}", clear: false)
        sleep 10 if special_circumstance
      else
        word = (%w(Woohoo Wow Wowzer Amazing Sheesh Spectacular Impressive) + ['Yeah buddy', 'You go girl']).sample
        display("\n#{word}, good job #{winner}!", clear: false)
        sleep 2
      end
    end

  end
end
