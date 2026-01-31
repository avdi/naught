# Shared test base class for Naught tests
#
# Provides common setup patterns and helper methods for testing
# null object configurations.
class NaughtTestCase < Minitest::Test
  # Build a null class with the given configuration block
  #
  # @yield [builder] configuration block
  # @return [Class] the generated null class
  def build_null_class(&)
    Naught.build(&)
  end

  # Build a null class and create an instance
  #
  # @yield [builder] configuration block
  # @return [Array(Class, Object)] the null class and instance
  def build_null(&)
    null_class = build_null_class(&)
    [null_class, null_class.new]
  end

  # Assert that an object responds to any method name
  #
  # @param obj [Object] the object to test
  def assert_responds_to_anything(obj)
    assert_respond_to obj, :foo
    assert_respond_to obj, :bar_baz
    assert_respond_to obj, :any_method_at_all
  end

  # Assert that a method returns nil
  #
  # @param obj [Object] the object to call the method on
  # @param method_name [Symbol] the method to call
  def assert_returns_nil(obj, method_name)
    assert_nil obj.public_send(method_name)
  end

  # Assert that a method returns self
  #
  # @param obj [Object] the object to call the method on
  # @param method_name [Symbol] the method to call
  def assert_returns_self(obj, method_name)
    assert_same obj, obj.public_send(method_name)
  end

  # Assert that an object is a null object
  #
  # @param obj [Object] the object to test
  def assert_null_object(obj)
    assert_operator Naught::NullObjectTag, :===, obj
  end

  # Refute that an object is a null object
  #
  # @param obj [Object] the object to test
  def refute_null_object(obj)
    refute_operator Naught::NullObjectTag, :===, obj
  end
end
