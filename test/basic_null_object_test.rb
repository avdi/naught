require "test_helper"

class BasicNullObjectTest < NaughtTestCase
  def setup
    @null_class, @null = build_null
  end

  def test_returns_nil_from_any_method
    assert_returns_nil @null, :info
    assert_returns_nil @null, :foobaz
    assert_returns_nil @null, :to_s
  end

  def test_accepts_any_arguments
    @null.foobaz(1, 2, 3)
  end

  def test_responds_to_any_method
    assert_responds_to_anything @null
  end

  def test_inspects_as_null
    assert_equal "<null>", @null.inspect
  end

  def test_knows_its_own_class
    assert_equal @null_class, @null.class
  end

  def test_aliases_new_to_get
    assert_same @null_class, @null_class.get.class
  end
end
