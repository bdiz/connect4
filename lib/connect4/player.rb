require 'connect4/disk'

module Connect4
  class Player

    def name
      self.class.to_s
    end

    def reset
      # override if player wants indication of a new game
    end

    def next_move board
      # must be overriden and return a column 0-6.
      raise NoImplementedError, "#{self.class}#next_move needs to be implemented."
    end

    def disk
      # if memoizing is removed, Space#<=> and Space#hash must change too.
      @disk ||= Disk.new(self)
    end

    def to_s
      name
    end

    def inspect options={}
      if options.fetch(:verbose, true)
        "#<#{self.class}:0x#{sprintf("%014x", self.object_id * 2)} @disk=#{disk.inspect(verbose: false)}>"
      else
        "#<#{self.class}:0x#{sprintf("%014x", self.object_id * 2)}>"
      end
    end

  end

end
