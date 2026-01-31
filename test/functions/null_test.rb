require "test_helper"

class NullFunctionTest < Minitest::Test
  include ConvertableNull::Conversions

  def test_given_no_input_returns_a_null_object
    assert_same ConvertableNull, Null().class
  end

  def test_given_nil_returns_a_null_object
    assert_same ConvertableNull, Null(nil).class
  end

  def test_given_a_null_object_returns_the_same_null_object
    null = ConvertableNull.get

    assert_same null, Null(null)
  end

  def test_given_anything_in_null_equivalents_returns_a_null_object
    assert_same ConvertableNull, Null("").class
  end

  def test_given_false_raises_an_argument_error
    assert_raises(ArgumentError) { Null(false) }
  end

  def test_given_a_non_empty_string_raises_an_argument_error
    assert_raises(ArgumentError) { Null("hello") }
  end

  def test_generates_null_objects_with_trace_info_for_file
    null, = Null(), __LINE__

    assert_equal __FILE__, null.__file__
  end

  def test_generates_null_objects_with_trace_info_for_line
    null, line = Null(), __LINE__

    assert_equal line, null.__line__
  end
end
