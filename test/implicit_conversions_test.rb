require "test_helper"

class ImplicitConversionsTest < NaughtTestCase
  def setup
    @null_class, @null = build_null(&:define_implicit_conversions)
  end

  def test_implicitly_splats_first_element_as_nil
    a, = @null

    assert_nil a
  end

  def test_implicitly_splats_second_element_as_nil
    _, b = @null

    assert_nil b
  end

  def test_is_implicitly_convertable_to_string
    assert_nil instance_eval(@null)
  end

  def test_implicitly_converts_to_an_empty_array
    assert_empty @null.to_ary
  end

  def test_implicitly_converts_to_an_empty_hash
    assert_empty @null.to_hash
  end

  def test_implicitly_converts_to_zero
    assert_equal 0, @null.to_int
  end

  def test_implicitly_converts_to_an_empty_string
    assert_equal "", @null.to_str
  end
end
