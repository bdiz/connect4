require 'connect4/disk'

module Connect4

  class Player

    include Comparable

    attr_accessor :disk_symbol, :grid

    class << self

      def inherited sub
        @players ||= []
        @players << sub
      end

      def players
        @players ? @players.map(&:new) : []
      end

      def name name
        @name = name
      end

      def get_name
        @name
      end

    end

    def name
      String(self.class.get_name || self.class)
    end

    def reset
      # override if player wants indication of a new game
    end

    def next_move
      # must be overriden and return a column 0-6.
      raise NoImplementedError, "#{self.class}#next_move needs to be implemented."
    end

    def disk
      Disk.new(self)
    end

    def <=> other
      if disk_symbol and other.disk_symbol
        disk_symbol <=> other.disk_symbol
      else
        object_id <=> other.object_id
      end
    end

    def to_s
      name
    end

  end

end
