require "test_helper"

class NullFunctionTest < NaughtTestCase
  include ConvertableNull::Conversions

  def test_given_no_input_returns_null_object
    assert_same ConvertableNull, Null().class
  end

  def test_given_nil_returns_null_object
    assert_same ConvertableNull, Null(nil).class
  end

  def test_given_null_object_returns_same_object
    null = ConvertableNull.get

    assert_same null, Null(null)
  end

  def test_given_null_equivalent_returns_null_object
    assert_same ConvertableNull, Null("").class
  end

  def test_given_false_raises_argument_error
    assert_raises(ArgumentError) { Null(false) }
  end

  def test_given_non_null_string_raises_argument_error
    assert_raises(ArgumentError) { Null("hello") }
  end

  def test_tracks_file_location
    null = Null()

    assert_equal __FILE__, null.__file__
  end

  def test_tracks_line_location
    null = Null()

    assert_equal __LINE__ - 2, null.__line__
  end
end
