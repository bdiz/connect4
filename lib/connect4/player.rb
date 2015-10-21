require 'connect4/disk'

module Connect4

  class Player

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

    def next_move
      # must be overriden and return a column 0-6.
      raise NoImplementedError, "#{self.class}#next_move needs to be implemented."
    end

    def reset
      # override if player wants indication of a new game
    end

    def disk
      Disk.new(self)
    end

    def manual
      false
    end

    def to_s
      name
    end

  end

end
