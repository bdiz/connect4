require 'connect4/space'

require 'colorize'

module Connect4
  class Board < Array

    NUMBER_OF_COLUMNS = 7
    NUMBER_OF_ROWS = 6
    NUMBER_OF_CONSECUTIVE_DISKS = 4
    ZERO_INDEX_OFFSET = 1

    BOARD_COLOR = :yellow
    DISK_SYMBOL = "\u2b24 ".colorize(background: BOARD_COLOR)
    LEFT_LEG = "\u2571"
    RIGHT_LEG = "\u2572"
    Space.symbol = DISK_SYMBOL.colorize(color: :light_black)

    class ColumnOverflowError < RuntimeError
    end
    class InvalidColumnPlayed < ArgumentError
    end

    class Column < Array
      def full?
        self.last.has_disk?
      end

      def empty?
        self.first.empty?
      end
    end

    def self.from_array array, player1, player2
      Connect4::Board.new.tap do |board|
        array.reverse.transpose.each_with_index do |column, column_index|
          column.each do |char|
            if char == 1
              board.insert(player1.disk, column_index)
            elsif char == 2
              board.insert(player2.disk, column_index)
            end
          end
        end
      end
    end

    def initialize
      super(Array.new(NUMBER_OF_COLUMNS) { Column.new(NUMBER_OF_ROWS) { Space.new } })
      NUMBER_OF_COLUMNS.times do |col|
        NUMBER_OF_ROWS.times do |row|
          space = board[col][row]
          space.col, space.row = col, row
          space.north = board[col][row+1]
          space.south = board[col][row-1] unless row == 0
          space.east  = board[col+1] && board[col+1][row]
          space.west  = board[col-1] && board[col-1][row] unless col == 0
          space.north_east = board[col+1] && board[col+1][row+1]
          space.south_east = board[col-1] && board[col-1][row+1] unless col == 0
          space.south_west = board[col-1] && board[col-1][row-1] unless col == 0 or row == 0
          space.north_west = board[col+1] && board[col+1][row-1] unless row == 0
        end
      end
      @restore_savepoint_operations = []
    end

    attr_reader :last_space_played

    def insert disk, column
      raise InvalidColumnPlayed, column unless (0..(NUMBER_OF_COLUMNS - ZERO_INDEX_OFFSET)).include?(column)
      @restore_savepoint_operations << {method: :remove, column: column}
      begin
        @last_space_played = board[column].last.insert(disk)
      rescue Space::OverflowError => e
        raise ColumnOverflowError, "in column #{column}", e.backtrace
      end
    end

    def remove column
      board[column].last.remove.tap do |disk|
        @restore_savepoint_operations << {method: :insert, column: column, disk: disk}
      end
    end

    def set_savepoint
      @restore_savepoint_operations = []
    end

    def restore_savepoint
      while !@restore_savepoint_operations.empty?
        operation = @restore_savepoint_operations.pop
        board[operation[:column]].last.send(operation[:method], *[operation[:disk]].compact)
      end
    end

    alias_method :restore, :restore_savepoint
    
    def full?
      board.map{|column| column.full? }.all?
    end

    def empty?
      board.map{|column| column.empty? }.all?
    end

    def to_s
      s = ''
      (0..NUMBER_OF_ROWS-ZERO_INDEX_OFFSET).to_a.reverse.each do |row|
        s += '   '
        NUMBER_OF_COLUMNS.times do |col|
          s += ' '.colorize(background: BOARD_COLOR)
          s += "#{board[col][row]}"
        end
        s += " ".colorize(background: BOARD_COLOR)
        s += "\n"
      end
      s += "     #{LEFT_LEG}               #{RIGHT_LEG}\n".colorize(:blue).bold
      return s
    end

    def to_a player1
      board.map do |column|
        column.map do |space|
          if space.has_disk?
            space.mine?(player1) ? 1 : 2
          end
        end
      end.transpose.reverse
    end

    private

    def board
      self
    end

  end

end
