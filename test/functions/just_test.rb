require "test_helper"

class JustTest < Minitest::Test
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

  def test_rejects_empty_string
    assert_raises(ArgumentError) { Just("") }
  end

  def test_rejects_null_objects
    assert_raises(ArgumentError) { Just(ConvertableNull.get) }
  end

  def test_raises_argument_error_when_block_yields_nil
    assert_raises(ArgumentError) { Just { nil } }
  end

  def test_returns_block_result_when_block_yields_non_nullish_value
    assert_equal "foo", Just { "foo" }
  end
end
