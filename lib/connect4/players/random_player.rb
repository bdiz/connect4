class RandomPlayer < Connect4::Player

  def next_move board
    moves = (0..6).to_a
    while !moves.empty?
      move = moves.sample
      if board.first[move].nil?
        return move
      else
        moves.delete(move)
      end
    end
  end

end
