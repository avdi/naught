require "test_helper"

class SingletonNullObjectTest < NaughtTestCase
  def setup
    @null_class = build_null_class(&:singleton)
  end

  def test_does_not_respond_to_new
    assert_raises(NoMethodError) { @null_class.new }
  end

  def test_has_only_one_instance
    assert_same @null_class.instance, @null_class.instance
  end

  def test_clone_and_dup_return_self
    null = @null_class.instance

    assert_same null, null.clone
    assert_same null, null.dup
  end

  def test_get_returns_the_singleton_instance
    assert_same @null_class.instance, @null_class.get
  end

  def test_get_ignores_arguments
    @null_class.get(42, foo: "bar")
  end
end
