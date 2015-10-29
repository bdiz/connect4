module Connect4

  class Disk

    attr_accessor :symbol
    attr_reader :player
    alias_method :owner, :player

    def initialize player
      @player = player
    end

    def mine? player
      @player == player
    end

    def theirs? player
      @player != player
    end

    def to_s
      symbol
    end

    def inspect options={}
      if options.fetch(:verbose, true)
        "#<#{self.class}:0x#{sprintf("%014x", self.object_id * 2)} @symbol=#{symbol ? symbol : 'nil'} @player=#{player.inspect(verbose: false)}>"
      else
        "#<#{self.class}:0x#{sprintf("%014x", self.object_id * 2)} @symbol=#{symbol ? symbol : 'nil'}>"
      end
    end

  end
end
