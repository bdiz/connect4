module Connect4

  class Space

    class << self
      private_methods :new
      def get
        @singleton ||= new
      end
    end

    attr_reader :player
    alias_method :owner, :player
    attr_accessor :to_s

    def empty?
      true
    end

    def mine? player
      false
    end

    def theirs? player
      false
    end

  end

  class Disk < Space
    include Comparable

    def initialize player
      @player = player
    end

    def empty?
      false
    end

    def mine? player
      @player == player
    end

    def theirs? player
      @player != player
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
