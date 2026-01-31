require "test_helper"

class SingletonNullObjectTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:singleton)
  end

  def test_does_not_respond_to_new
    assert_raises(NoMethodError) { @null_class.new }
  end

  def test_has_only_one_instance
    null1 = @null_class.instance
    null2 = @null_class.instance

    assert_same null1, null2
  end

  def test_can_be_cloned
    null = @null_class.instance

    assert_same null, null.clone
  end

  def test_can_be_duplicated
    null = @null_class.instance

    assert_same null, null.dup
  end

  def test_aliases_instance_to_get
    assert_same @null_class.instance, @null_class.get
  end

  def test_permits_arbitrary_arguments_to_be_passed_to_get
    @null_class.get(42, foo: "bar")
  end
end
