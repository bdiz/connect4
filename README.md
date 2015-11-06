# Connect4

Connect4 provides the board and tournament code so you can go head-to-head
with your friends using your own Connect4 brainiac algorithms.

## Usage

Git clone this repo, bundle install, and add a ruby file into `lib/connect4/players`. For example,

    $ git clone https://github.com/bdiz/connect4.git
    $ cd connect4
    $ bundle
    $ vi lib/connect4/players/my_player.rb

```ruby
class MyPlayer < Connect4::Player

  # Return the column number of your next move (0-6).
  # +board+ is an array of arrays. 1 indicates your disk. 2 indicates your opponents disk.
  # [
  #   [nil, nil, nil, nil, nil, nil, nil],
  #   [nil, nil, nil, nil, nil, nil, nil],
  #   [nil, nil, nil, nil, nil, nil, nil],
  #   [nil, nil,   2, nil, nil, nil, nil],
  #   [nil, nil,   1,   2, nil, nil, nil],
  #   [  2,   1,   1,   1,   2, nil, nil]
  # ]
  def next_move board
    board.each do |column|
      column.each do |row|
        # ..do some nifty analysis
      end
    end
    # return a column number
    return rand(0..6)
  end

end
```

Then execute:

    $ bin/connect4

These are the environment variables that are supported:

  * `$DEBUG=true` will not catch any exceptions of your `Connect4::Player`.
  * `$VERBOSE=false` will silence any output.
  * `$TIMEOUT=1.5` will use a player move timeout of 1.5 seconds.
  * `$GAMES=99` will play opponents against each other 99 times per match.
  * `$GAMES_TO_DISPLAY=2` will only show the first 2 games before playing the rest of the games fast.

For example, to play 5 games fast with a 1.5 second timeout:

    $ GAMES=5 GAMES_TO_DISPLAY=0 TIMEOUT=1.5 bin/connect4

## Contributing

1. Fork it ( https://github.com/[my-github-username]/connect4/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
