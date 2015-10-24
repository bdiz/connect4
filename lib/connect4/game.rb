require 'connect4/board'
require 'connect4/display'
require 'timeout'

module Connect4
  class Game

    include Display

    class PlayerTimeout < Timeout::Error
    end

    TIME_ALLOWED_PER_MOVE = 0.25
    TIME_BETWEEN_DISPLAYS = 1.5
    PLAYER1_DISK = Board::DISK.colorize(color: :red, background: Board::BOARD_COLOR)
    PLAYER2_DISK = Board::DISK.colorize(color: :black, background: Board::BOARD_COLOR)

    attr_reader :winner, :special_circumstance

    def initialize player1, player2, options={}
      raise ArgumentError, "Player instances are same." if player1.object_id == player2.object_id

      @player1, @player2 = player1, player2

      @player1.reset
      @player2.reset

      @player1.disk.symbol ||= PLAYER1_DISK
      @player2.disk.symbol ||= PLAYER2_DISK

      @boards = [Board.new, Board.new, Board.new]
      @board, @player1.board, @player2.board = @boards
      @turn = [@player1, @player2]
      @winner = nil
      @draw = false

      @special_circumstance = nil
      @column_overflowed = false
      @player_timeout = false
      @invalid_column_played = false
      @player_crashed = false

      @verbose = options[:verbose] || false
      @time_between_displays = TIME_BETWEEN_DISPLAYS
    end

    def play
      display self if @verbose
      determine_winner do
        while !game_over?
          column = nil
          restore_boards do
            keep_time! do
              column = @turn.rotate!.last.next_move
            end
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

    def to_s
      [@player1, @player2].sort.reverse.map do |player|
        "#{player.disk.symbol} #{player} (#{player.wins} #{player.wins == 1 ? 'win' : 'wins'})"
      end
      .join("\n") + "\n\n" + @board.to_s
    end

    private

    def restore_boards &block
      @player1.board.set_savepoint
      @player2.board.set_savepoint
      block.call
      @player1.board.restore_savepoint
      @player2.board.restore_savepoint
    end

    def play_disk column
      @boards.each {|board| board.insert(@turn.last.disk, column) }
    end

    def set_winner player
      player.add_win
      @winner = player
    end

    def determine_winner &block
      block.call
      set_winner(@turn.last) unless draw?
    rescue Column::OverflowError => e
      @special_circumstance = "#{@turn.last} put a disk #{e.message} when it was full. #{@turn.first} wins."
      @column_overflowed = true
      set_winner(@turn.first)
    rescue PlayerTimeout => e
      @special_circumstance = "#{@turn.last} took too long to play - timeout. #{@turn.first} wins."
      @player_timeout = true
      set_winner(@turn.first)
    rescue Board::InvalidColumnPlayed => e
      @invalid_column_played = true
      @special_circumstance = "#{@turn.last} played into an invalid column, #{e.message.inspect}. #{@turn.first} wins."
      set_winner(@turn.first)
    rescue => e
      @player_crashed = true
      @special_circumstance = "#{@turn.last} crashed with a #{$!.class}. #{@turn.first} wins."
      set_winner(@turn.first)
    ensure
      raise e if e and eval("#{ENV['DEBUG']}")
    end

    def game_over?
      @board.has_consecutive_disks? || (@draw = @board.full?)
    end

    def keep_time! &block
      Timeout::timeout(Float(ENV.fetch('TIMEOUT', TIME_ALLOWED_PER_MOVE)), PlayerTimeout) { block.call }
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
