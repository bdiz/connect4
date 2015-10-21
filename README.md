# Connect4

Connect4 provides the grid and tournament code so you can go head-to-head
with your friends using your own Connect4 brainiac algorithms.

## Usage

Git clone this repo and add a ruby file into `lib/connect4/players`. For example,

```ruby
# lib/connect4/players/my_player.rb

class MyPlayer < Connect4::Player
  name 'Me'

  # Returns the column number of your next move.
  def next_move
    # grid is an Array of Arrays of comparable Connect4:Disk objects.
    grid.each do |column|
      column.each do |row|
        # ..do some nifty analysis and return a column number
        return rand(0..6)
      end
    end
  end

end
```

And then execute:

    $ bin/connect4

Environment variables supported are `$DEBUG`, `$VERBOSE` and `$GAMES`.

  * `$DEBUG=true` will not catch any exceptions of your `Connect4::Player`.
  * `$VERBOSE=false` will silence any output.
  * `$GAMES=99` will play opponents against each other 99 times per match.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/connect4/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
