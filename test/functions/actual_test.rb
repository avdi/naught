require "test_helper"

class ActualTest < Minitest::Test
  include ConvertableNull::Conversions

  def test_given_a_null_object_returns_nil
    null = ConvertableNull.get

    assert_nil Actual(null)
  end

  def test_given_false_returns_false_unchanged
    refute Actual(false)
  end

  def test_given_a_string_returns_the_string_unchanged
    str = "hello"

    assert_same str, Actual(str)
  end

  def test_given_nil_returns_nil
    assert_nil Actual(nil)
  end

  def test_returns_nil_when_block_yields_null_object
    assert_nil Actual { ConvertableNull.new }
  end

  def test_returns_block_result_when_block_yields_non_null
    assert_equal "foo", Actual { "foo" }
  end
end
