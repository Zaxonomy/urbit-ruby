require "test_helper"

class Urbit::PierTest < Minitest::Test
  def setup
    @p = Urbit::Api::Pier.new
  end

  def test_a_pier_has_a_pat_p
    refute_nil @p.pat_p
    assert_equal "~zod", @p.pat_p
  end

  def test_is_not_initially_logged_in
    refute @p.logged_in?
  end

  def test_can_log_in
    # NOTE: This test will fail if you don''t have a fake zod running.
    @p.login
    assert @p.logged_in?
    refute_nil @p.cookie
  end

   def test_can_open_a_channel
     @p.open_channel "Test Channel"
     assert_equal 1, @p.open_channels.size
   end
end
