require 'connect4/player'

class Player1 < Connect4::Player
  name 'Laney'

  def next_move
    return rand(0..6)
  end

end

class Player2 < Connect4::Player
  name 'Ben'

  def next_move
    return rand(0..6)
  end

end

class GoodPlayer < Connect4::Player
  name 'smartie'

  def next_move
    return 0
  end

end

class BadPlayer < Connect4::Player
  name 'dumby'

  def reset
    @moves = [6,4,5]
  end

  def next_move
    return @moves.rotate!.first
  end

end

class PredictablePlayer < Connect4::Player
  name 'predictable'

  def initialize column
    @column = column
  end

  def next_move
    return @column
  end

end

class SlowPlayer < Connect4::Player
  name 'turtle'

  def next_move
    sleep 0.3
    return rand(0..6)
  end

end

class InvalidColumnPlayer < Connect4::Player
  name 'invalid_column'

  def reset
    @move = [5, 6, 7]
  end

  def next_move
    return @move.shift
  end

end

class ExceptionalPlayer < Connect4::Player
  name 'boom'

  def next_move
    raise RuntimeError, "Something went wrong."
  end

end

class ManualPlayer < Connect4::Player
  name 'Emanuel'

  def next_move
    print "Your turn, #{name} (1-7): "
    return Integer(gets)-1
  end

  def manual
    true
  end

end
