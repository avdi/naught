require "test_helper"

class MaybeTest < NaughtTestCase
  include ConvertableNull::Conversions

  def test_given_nil_returns_null_object
    assert_same ConvertableNull, Maybe(nil).class
  end

  def test_given_null_object_returns_same_object
    null = ConvertableNull.get

    assert_same null, Maybe(null)
  end

  def test_given_null_equivalent_returns_null_object
    assert_same ConvertableNull, Maybe("").class
  end

  def test_given_false_returns_false
    refute Maybe(false)
  end

  def test_given_string_returns_string
    str = "hello"

    assert_same str, Maybe(str)
  end

  def test_tracks_file_location
    null = Maybe()

    assert_equal __FILE__, null.__file__
  end

  def test_tracks_line_location
    null = Maybe()

    assert_equal __LINE__ - 2, null.__line__
  end

  def test_block_yielding_nil_returns_null_object
    assert_equal ConvertableNull, Maybe { nil }.class
  end

  def test_block_yielding_value_returns_value
    assert_equal "foo", Maybe { "foo" }
  end
end
