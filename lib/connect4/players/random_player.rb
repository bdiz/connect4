class RandomPlayer < Connect4::Player
  name 'Random'

  def next_move
    return rand(0..6)
  end

end
