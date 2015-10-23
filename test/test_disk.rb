require 'minitest_helper'

describe Connect4::Disk do

  include Fixtures

  it 'knows if it belongs to a player' do
    me = Connect4::Player.new
    them = Connect4::Player.new

    my_disk = Connect4::Disk.new(me)
    my_disk.owner.must_equal me
    my_disk.mine?(me).must_equal true
    my_disk.theirs?(me).must_equal false

    their_disk = Connect4::Disk.new(them)
    their_disk.owner.must_equal them
    their_disk.mine?(me).must_equal false
    their_disk.theirs?(me).must_equal true

    nobodys_disk = Connect4::Space.get
    nobodys_disk.owner.must_equal nil
    nobodys_disk.mine?(me).must_equal false
    nobodys_disk.theirs?(me).must_equal false
  end

  it 'knows if it is an empty disk' do
    player = Connect4::Player.new

    somebodys_disk = Connect4::Disk.new(player)
    somebodys_disk.empty?.must_equal false

    nobodys_disk = Connect4::Space.get
    nobodys_disk.empty?.must_equal true
  end

end
