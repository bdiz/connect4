module Connect4
  class Disk
    include Comparable
    attr_reader :player

    def initialize player
      @player = player
    end

    def <=> other
      @player.object_id <=> other.player.object_id
    end

    alias_method :eql?, :==
    def hash
      @player.object_id.hash
    end

    def to_s
      @player.disk_symbol
    end

    def inspect
      to_s
    end

  end
end
