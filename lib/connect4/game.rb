require 'connect4/grid'
require 'connect4/display'
require 'timeout'

module Connect4
  class Game

    include Display

    class PlayerTimeout < Timeout::Error
    end

    TIME_ALLOWED_PER_MOVE = 0.25
    TIME_BETWEEN_DISPLAYS = 1.5
    PLAYER1_DISK = Grid::DISK.colorize(color: :red, background: Grid::BOARD_COLOR)
    PLAYER2_DISK = Grid::DISK.colorize(color: :black, background: Grid::BOARD_COLOR)

    attr_reader :winner, :special_circumstance

    def initialize player1, player2, options={}
      raise ArgumentError, "Player instances are same." if player1.object_id == player2.object_id

      @player1, @player2 = player1, player2

      @player1.reset
      @player2.reset

      @player1.disk_symbol ||= PLAYER1_DISK
      @player2.disk_symbol ||= PLAYER2_DISK

      @grids = [Grid.new, Grid.new, Grid.new]
      @grid, @player1.grid, @player2.grid = @grids
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
          keep_time! do
            play_disk(@turn.rotate!.last.next_move)
          end
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
      {
        @player1.disk_symbol => @player1,
        @player2.disk_symbol => @player2
      }
      .sort.reverse.map do |disk_symbol, player|
        "#{player.disk_symbol} #{player} (#{player.wins} #{player.wins == 1 ? 'win' : 'wins'})"
      end
      .join("\n") + "\n\n" + @grid.to_s
    end

    private

    def play_disk column
      @grids.each {|grid| grid.insert(@turn.last.disk, column) }
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
    rescue Grid::InvalidColumnPlayed => e
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
      @grid.has_consecutive_disks? || (@draw = @grid.full?)
    end

    def keep_time! &block
      if @turn.rotate.last.manual
        block.call
      else
        Timeout::timeout(TIME_ALLOWED_PER_MOVE, PlayerTimeout) { block.call }
      end
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