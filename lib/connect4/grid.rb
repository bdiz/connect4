require 'connect4/column'
require 'connect4/core_ext/array'

require 'colorize'

module Connect4
  class Grid < Array

    NUMBER_OF_COLUMNS = 7
    NUMBER_OF_ROWS = 6
    NUMBER_OF_CONSECUTIVE_DISKS = 4
    ZERO_INDEX_OFFSET = 1

    DISK = "\u2b24 "
    LEFT_LEG = "\u2571"
    RIGHT_LEG = "\u2572"
    BOARD_COLOR = :yellow
    EMPTY_COLORING = { color: :light_black, background: BOARD_COLOR }
    EMPTY_SPOT = DISK.colorize(EMPTY_COLORING)

    class OverflowError < RuntimeError
    end
    class InvalidColumnPlayed < ArgumentError
    end

    def initialize columns=nil
      super(columns || Array.new(NUMBER_OF_COLUMNS) { Column.new(NUMBER_OF_ROWS) })
    end

    def insert disk, column
      raise InvalidColumnPlayed, column unless (0..6).include?(column)
      begin
        columns[column].insert(disk)
      rescue Column::OverflowError => e
        raise e, "in column #{column}", e.backtrace
      end
    end
    
    def full?
      columns.flatten.none?(&:nil?)
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
        shift_amount.times { column.unshift(nil) }
        (NUMBER_OF_COLUMNS - ZERO_INDEX_OFFSET - shift_amount).times { column << nil }
        offset_columns << column
      end
      consecutive_disks(offset_columns.transpose)
    end

    def to_s
      s = ''
      (0..NUMBER_OF_ROWS-ZERO_INDEX_OFFSET).to_a.reverse.each do |row|
        s += '   '
        columns.each_with_index do |column, index|
          s += ' '.colorize(EMPTY_COLORING) unless index == 0
          s += "#{column[row] || EMPTY_SPOT}"
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
