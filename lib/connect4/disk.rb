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
    attr_accessor :symbol

    def empty?
      true
    end

    def mine? player
      false
    end

    def theirs? player
      false
    end

    def to_s
      @symbol
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
      if symbol and other.symbol
        symbol <=> other.symbol
      else
        object_id <=> other.object_id
      end
    end

    alias_method :eql?, :==
    def hash
      @player.object_id.hash
    end

    def inspect
      to_s
    end

  end
end
