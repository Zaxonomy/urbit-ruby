require "test_helper"

class Urbit::PierTest < Minitest::Test
  def test_a_pier_has_a_pat_p
    p = Urbit::Api::Pier.new
    refute_nil p.pat_p
    assert_equal '~zod', p.pat_p
  end

  def test_is_not_initially_logged_in
    p = Urbit::Api::Pier.new
    refute p.logged_in?
  end

  def test_can_log_in
    # NOTE: This test will fail if you don't have a fake zod running.
    p = Urbit::Api::Pier.new
    p.login
    assert p.logged_in?
    refute_nil p.cookie
  end

end
