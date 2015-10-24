require 'connect4/disk'
require 'connect4/column'
require 'connect4/core_ext/array'

require 'colorize'

module Connect4
  class Board< Array

    NUMBER_OF_COLUMNS = 7
    NUMBER_OF_ROWS = 6
    NUMBER_OF_CONSECUTIVE_DISKS = 4
    ZERO_INDEX_OFFSET = 1

    DISK = "\u2b24 "
    LEFT_LEG = "\u2571"
    RIGHT_LEG = "\u2572"
    BOARD_COLOR = :yellow
    Space.get.symbol = DISK.colorize(color: :light_black, background: BOARD_COLOR)

    class OverflowError < RuntimeError
    end
    class InvalidColumnPlayed < ArgumentError
    end

    def initialize columns=nil
      super(columns || Array.new(NUMBER_OF_COLUMNS) { Column.new(NUMBER_OF_ROWS, Space.get) })
      @restore_savepoint_operations = []
    end

    def insert disk, column
      raise InvalidColumnPlayed, column unless (0..6).include?(column)
      @restore_savepoint_operations << {method: :remove, column: column}
      begin
        columns[column].insert(disk)
      rescue Column::OverflowError => e
        raise e, "in column #{column}", e.backtrace
      end
    end

    def remove column
      columns[column].remove.tap do |disk|
        @restore_savepoint_operations << {method: :insert, column: column, disk: disk}
      end
    end

    def set_savepoint
      @restore_savepoint_operations = []
    end

    def restore_savepoint
      while !@restore_savepoint_operations.empty?
        operation = @restore_savepoint_operations.pop
        columns[operation[:column]].send(operation[:method], *[operation[:disk]].compact)
      end
    end

    alias_method :restore, :restore_savepoint
    
    def full?
      columns.flatten.none?(&:empty?)
    end

    def has_consecutive_disks?
      !!(
        consecutive_vertical_disks.first ||
        consecutive_horizontal_disks.first ||
        consecutive_diagonal_disks(:falling).first ||
        consecutive_diagonal_disks(:rising).first
      )
    end

    def consecutive_vertical_disks
      consecutive_disks(columns)
    end

    def consecutive_horizontal_disks
      consecutive_disks(columns.transpose)
    end
 
    def consecutive_diagonal_disks angle
      offset_columns = []
      temp_columns = (angle == :falling) ? columns : columns.reverse
      temp_columns.each_with_index do |column, shift_amount|
        column = column.dup
        shift_amount.times { column.unshift(Space.get) }
        (NUMBER_OF_COLUMNS - ZERO_INDEX_OFFSET - shift_amount).times { column << Space.get }
        offset_columns << column
      end
      consecutive_disks(offset_columns.transpose)
    end

    def to_s
      s = ''
      (0..NUMBER_OF_ROWS-ZERO_INDEX_OFFSET).to_a.reverse.each do |row|
        s += '   '
        columns.each_with_index do |column, index|
          s += ' '.colorize(background: BOARD_COLOR) unless index == 0
          s += "#{column[row]}"
        end
        s += "\n"
      end
      s += "    #{LEFT_LEG}               #{RIGHT_LEG}\n".colorize(:blue).bold
      return s
    end

    private

    def consecutive_disks array
      array.each_with_object([]) do |column, sets_of_disks|
        column.
          consecutive_sets(NUMBER_OF_CONSECUTIVE_DISKS).
          each {|set| sets_of_disks << set }
      end
    end

    def columns
      self
    end

  end

end
