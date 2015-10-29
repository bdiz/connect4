class PersistentPlayer < Connect4::Player

  def reset
    @moves = (0..6).to_a.shuffle
  end

  def next_move board
    while !@moves.empty?
      @move ||= @moves.sample
      if board.first[@move].nil?
        return @move
      else
        @move = @moves.delete(@move)
      end
    end
  end

end
