require "test_helper"

class ExplicitConversionsTest < NaughtTestCase
  def setup
    @null_class, @null = build_null(&:define_explicit_conversions)
  end

  def test_converts_to_empty_string
    assert_equal "", @null.to_s
  end

  def test_converts_to_empty_array
    assert_empty @null.to_a
  end

  def test_converts_to_zero_integer
    assert_equal 0, @null.to_i
  end

  def test_converts_to_zero_float
    assert_in_delta 0.0, @null.to_f
  end

  def test_converts_to_empty_hash
    assert_empty @null.to_h
  end
end
