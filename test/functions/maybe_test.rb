require "test_helper"

class MaybeTest < Minitest::Test
  include ConvertableNull::Conversions

  def test_given_nil_returns_a_null_object
    assert_same ConvertableNull, Maybe(nil).class
  end

  def test_given_a_null_object_returns_the_same_null_object
    null = ConvertableNull.get

    assert_same null, Maybe(null)
  end

  def test_given_anything_in_null_equivalents_returns_a_null_object
    assert_same ConvertableNull, Maybe("").class
  end

  def test_given_false_returns_false_unchanged
    refute Maybe(false)
  end

  def test_given_a_string_returns_the_string_unchanged
    str = "hello"

    assert_same str, Maybe(str)
  end

  def test_generates_null_objects_with_trace_info_for_file
    null, = Maybe(), __LINE__

    assert_equal __FILE__, null.__file__
  end

  def test_generates_null_objects_with_trace_info_for_line
    null, line = Maybe(), __LINE__

    assert_equal line, null.__line__
  end

  def test_returns_null_object_when_block_yields_nil
    assert_equal ConvertableNull, Maybe { nil }.class
  end

  def test_returns_block_result_when_block_yields_non_nullish_value
    assert_equal "foo", Maybe { "foo" }
  end
end
