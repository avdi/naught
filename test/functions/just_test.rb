require "test_helper"

class JustTest < NaughtTestCase
  include ConvertableNull::Conversions

  def test_passes_false_through
    refute Just(false)
  end

  def test_passes_strings_through
    str = "hello"

    assert_same str, Just(str)
  end

  def test_rejects_nil
    assert_raises(ArgumentError) { Just(nil) }
  end

  def test_rejects_null_equivalent
    assert_raises(ArgumentError) { Just("") }
  end

  def test_rejects_null_objects
    assert_raises(ArgumentError) { Just(ConvertableNull.get) }
  end

  def test_block_yielding_nil_raises_argument_error
    assert_raises(ArgumentError) { Just { nil } }
  end

  def test_block_yielding_value_returns_value
    assert_equal "foo", Just { "foo" }
  end
end
