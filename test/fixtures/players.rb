require 'connect4/player'

class Player1 < Connect4::Player

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

class Player2 < Player1
end

class GoodPlayer < Connect4::Player

  def next_move board
    return 0
  end

end

class BadPlayer < Connect4::Player

  def reset
    @moves = [6,4,5]
  end

  def next_move board
    return @moves.rotate!.first
  end

end

class PredictablePlayer < Connect4::Player

  def initialize column
    @column = column
  end

  def next_move board
    return @column
  end

end

class SlowPlayer < Connect4::Player

  def next_move board
    sleep 0.3
    return rand(0..6)
  end

end

class InvalidColumnPlayer < Connect4::Player

  def reset
    @move = [5, 6, 7]
  end

  def next_move board
    return @move.shift
  end

end

class ExceptionalPlayer < Connect4::Player

  def next_move board
    raise RuntimeError, "Something went wrong."
  end

end
