require "test_helper"

class ActualTest < NaughtTestCase
  include ConvertableNull::Conversions

  def test_given_null_object_returns_nil
    assert_nil Actual(ConvertableNull.get)
  end

  def test_given_false_returns_false
    refute Actual(false)
  end

  def test_given_string_returns_string
    str = "hello"

    assert_same str, Actual(str)
  end

  def test_given_nil_returns_nil
    assert_nil Actual(nil)
  end

  def test_block_yielding_null_object_returns_nil
    assert_nil Actual { ConvertableNull.new }
  end

  def test_block_yielding_value_returns_value
    assert_equal "foo", Actual { "foo" }
  end
end
