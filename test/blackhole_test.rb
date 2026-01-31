require "test_helper"

class BlackholeTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:black_hole)
    @null = @null_class.new
  end

  def test_returns_self_from_info_method_call
    assert_same @null, @null.info
  end

  def test_returns_self_from_foobaz_method_call
    assert_same @null, @null.foobaz
  end

  def test_returns_self_from_shift_method_call
    assert_same @null, @null << "bar"
  end
end
