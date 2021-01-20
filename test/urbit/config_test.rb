require "test_helper"

class Urbit::ConfigTest < Minitest::Test
  def test_config_reads_in_the_pier_code
    c = Urbit::Api::Config.new
    assert_equal 'lidlut-tabwed-pillex-ridrup', c.pier_code
  end

  def test_config_reads_in_the_pier_name
    c = Urbit::Api::Config.new
    assert_equal c.pier_name, '~zod'
  end
end
