require "test_helper"

class Urbit::ChannelTest < Minitest::Test
  def test_a_Channel_is_initialized_with_a_name
    c = Urbit::Api::Channel.new "Test Channel"
    refute_nil c.name
    assert_equal 'Test Channel', c.name
  end
end
