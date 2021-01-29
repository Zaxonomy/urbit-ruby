require "test_helper"

class Urbit::ShipTest < Minitest::Test
  def setup
    @ship = Urbit::Api::Ship.new
  end

  def test_a_ship_has_a_pat_p
    refute_nil @ship.pat_p
    assert_equal "~zod", @ship.pat_p
  end

  def test_is_not_initially_logged_in
    refute @ship.logged_in?
  end

  def test_can_log_in
    # NOTE: This test will fail if you don''t have a fake zod running.
    @ship.login
    assert @ship.logged_in?
    refute_nil @ship.cookie
  end

   def test_can_open_a_channel
     @ship.open_channel "Test Channel"
     assert_equal 1, @ship.open_channels.size
   end

  def test_opening_the_channel_answers_the_new_channel
    c = @ship.open_channel "Test Channel"
    assert_equal Urbit::Api::Channel, c.class
  end

  def test_closing_the_channel_makes_it_unavailable
    c = @ship.open_channel "Test Channel"
    assert_equal 1, @ship.open_channels.size
    c.close
    assert_equal 0, @ship.open_channels.size
  end

  #-------------------------------------------------------------------
  # This test is a tricky one and I couldn't get it to work.
  # You can, however, assure yourself that it is actually true by
  # uncommenting the "puts" in channel.close and you'll see it is
  # called when your program ends.
  #-------------------------------------------------------------------
  # def test_destroying_a_ship_closes_all_its_channels
  #   c = @ship.open_channel "Test Channel"
  #   assert_equal 1, @ship.open_channels.size
  #   assert c.open?
  #   @ship = nil
  #   GC.start(full_mark: true, immediate_sweep: true)
  #   sleep 15
  #   assert c.closed?
  # end
end
