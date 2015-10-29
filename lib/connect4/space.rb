require 'delegate'

module Connect4
  class Space

    class OverflowError < RuntimeError
    end
    class UnderflowError < RuntimeError
    end

    class << self
      attr_accessor :symbol
    end

    include Comparable

    attr_accessor :col, :row
    attr_accessor :north, :east, :south, :west
    attr_accessor :north_east, :south_east, :south_west, :north_west

    def initialize disk=nil
      @disk = disk
    end

    def insert disk
      raise OverflowError unless empty?
      if south.is_a?(Space) and south.empty?
        south.insert disk
      else
        @disk = disk
        self
      end
    end

    def part_of_consecutive?
      part_of_vertical? or part_of_horizontal? or part_of_rising_diagonal? or part_of_falling_diagonal?
    end

    def part_of_vertical?
      !empty? && (direction_count(:north, disk) + direction_count(:south, disk) + 1) >= Board::NUMBER_OF_CONSECUTIVE_DISKS
    end

    def part_of_horizontal?
      !empty? && (direction_count(:west, disk) + direction_count(:east, disk) + 1) >= Board::NUMBER_OF_CONSECUTIVE_DISKS
    end

    def part_of_rising_diagonal?
      !empty? && (direction_count(:south_west, disk) + direction_count(:north_east, disk) + 1) >= Board::NUMBER_OF_CONSECUTIVE_DISKS
    end

    def part_of_falling_diagonal?
      !empty? && (direction_count(:north_west, disk) + direction_count(:south_east, disk) + 1) >= Board::NUMBER_OF_CONSECUTIVE_DISKS
    end

    def direction_count direction, disk, count=0
      space = self.send(direction)
      if space && space.mine?(disk.player)
        space.direction_count(direction, disk, count+1)
      else
        return count
      end
    end

    def remove
      if !empty?
        disk.tap { @disk = nil }
      elsif south.is_a?(Space)
        south.remove
      else
        raise UnderflowError
      end
    end

    def empty?
      !disk
    end

    def has_disk?
      !!disk
    end

    def player
      disk && disk.player
    end

    def owner
      disk && disk.owner
    end

    def mine? player
      (disk && disk.mine?(player)) || false
    end

    def theirs? player
      (disk && disk.theirs?(player)) || false
    end

    def <=> other
      disk.object_id <=> other.disk.object_id
    end

    def symbol
      if empty?
        Space.symbol
      else
        disk.symbol
      end
    end

    def to_s
      symbol
    end

    def inspect
      "#<#{self.class}:0x#{sprintf("%014x", self.object_id * 2)} @row=#{@row} @col=#{@col} @disk=#{disk.inspect}>"
    end

    protected

    def disk
      @disk
    end

  end
end
