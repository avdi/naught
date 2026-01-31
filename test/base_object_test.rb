require "test_helper"

class BaseObjectTest < Minitest::Test
  def setup
    @custom_base_null_class = Naught.build do |b|
      b.base_class = Object
    end
    @null = @custom_base_null_class.new
  end

  def test_responds_to_base_class_methods
    assert_kind_of Array, @null.methods
  end

  def test_responds_to_unknown_methods
    assert_nil @null.foo
  end

  def test_exposes_the_default_base_class_choice
    default_base_class = :not_set
    Naught.build do |b|
      default_base_class = b.base_class
    end

    assert_equal Naught::BasicObject, default_base_class
  end
end

class BaseObjectSingletonTest < Minitest::Test
  def setup
    @custom_base_singleton_null_class = Naught.build do |b|
      b.singleton
      b.base_class = Object
    end
    @null_instance = @custom_base_singleton_null_class.instance
  end

  def test_can_be_cloned
    assert_same @null_instance, @null_instance.clone
  end

  def test_can_be_duplicated
    assert_same @null_instance, @null_instance.dup
  end
end
