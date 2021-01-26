require "test_helper"

class Urbit::ConfigTest < Minitest::Test
  def test_config_reads_in_the_ship_code
    c = Urbit::Api::Config.new
    assert_equal 'lidlut-tabwed-pillex-ridrup', c.ship_code
  end

  def test_config_reads_in_the_ship_name
    c = Urbit::Api::Config.new
    assert_equal c.ship_name, '~zod'
  end
end
