require "test_helper"

class NullSafeProxyTest < NaughtTestCase
  def setup
    @null_class = Naught.build do |b|
      b.null_safe_proxy
    end
  end

  def null_safe(obj)
    @null_class::Conversions.instance_method(:NullSafe).bind_call(self, obj)
  end

  def test_null_safe_wraps_regular_object
    obj = Object.new
    proxy = null_safe(obj)

    assert_equal "<null-safe-proxy(#{obj.inspect})>", proxy.inspect
  end

  def test_null_safe_passes_through_null_object
    null = @null_class.new
    result = null_safe(null)

    assert_same null, result
  end

  def test_null_safe_converts_nil_to_null
    result = null_safe(nil)

    assert_null_object result
    assert_equal @null_class, result.class
  end

  def test_proxy_returns_null_when_method_returns_nil
    obj = Object.new
    def obj.foo
      nil
    end
    proxy = null_safe(obj)
    result = proxy.foo

    assert_null_object result
  end

  def test_proxy_wraps_non_nil_return_values
    obj = Object.new
    def obj.foo
      "hello"
    end
    proxy = null_safe(obj)
    result = proxy.foo

    assert_includes result.inspect, "null-safe-proxy"
    assert_includes result.inspect, "hello"
  end

  def test_chained_calls_propagate_proxy
    obj = Object.new
    def obj.foo
      inner = Object.new
      def inner.bar
        "result"
      end
      inner
    end
    proxy = null_safe(obj)
    result = proxy.foo.bar

    assert_includes result.inspect, "null-safe-proxy"
    assert_includes result.inspect, "result"
  end

  def test_nil_in_chain_returns_null_object
    obj = Object.new
    def obj.foo
      inner = Object.new
      def inner.bar
        nil
      end
      inner
    end
    proxy = null_safe(obj)
    result = proxy.foo.bar

    assert_null_object result
  end

  def test_can_chain_after_nil_with_black_hole
    null_class = Naught.build do |b|
      b.black_hole
      b.null_safe_proxy
    end

    null_safe_method = null_class::Conversions.instance_method(:NullSafe)

    obj = Object.new
    def obj.foo
      nil
    end

    result = null_safe_method.bind_call(self, obj).foo.bar.baz

    assert_null_object result
  end

  def test_proxy_responds_to_target_methods
    obj = Object.new
    def obj.custom_method
      42
    end
    proxy = null_safe(obj)

    assert_respond_to proxy, :custom_method
  end

  def test_proxy_target_accessible
    obj = Object.new
    proxy = null_safe(obj)

    assert_same obj, proxy.__target__
  end

  def test_proxy_is_null_safe_proxy
    obj = Object.new
    proxy = null_safe(obj)

    assert_operator Naught::NullSafeProxyTag, :===, proxy
  end

  def test_unwrapping_with_actual
    obj = "hello"
    proxy = null_safe(obj)
    inner_proxy = proxy.upcase
    actual_value = inner_proxy.__target__

    assert_equal "HELLO", actual_value
  end

  def test_with_custom_null_equivalents
    null_class = Naught.build do |b|
      b.null_equivalents << false
      b.null_safe_proxy
    end

    null_safe_method = null_class::Conversions.instance_method(:NullSafe)

    obj = Object.new
    def obj.falsey
      false
    end
    proxy = null_safe_method.bind_call(self, obj)
    result = proxy.falsey

    assert_null_object result
  end

  def test_null_safe_with_false_default_not_null
    obj = Object.new
    def obj.falsey
      false
    end
    proxy = null_safe(obj)
    result = proxy.falsey

    assert_includes result.inspect, "null-safe-proxy"
    assert_includes result.inspect, "false"
  end

  def test_proxy_passes_block_to_method
    obj = [1, 2, 3]
    proxy = null_safe(obj)
    result = proxy.map { |x| x * 2 }

    assert_includes result.inspect, "null-safe-proxy"
    assert_equal [2, 4, 6], result.__target__
  end

  def test_proxy_passes_arguments_to_method
    obj = "hello world"
    proxy = null_safe(obj)
    result = proxy.split(" ")

    assert_includes result.inspect, "null-safe-proxy"
    assert_equal ["hello", "world"], result.__target__
  end

  def test_proxy_passes_through_null_object_from_method
    null = @null_class.new
    obj = Object.new
    obj.define_singleton_method(:get_null) { null }
    proxy = null_safe(obj)
    result = proxy.get_null

    assert_same null, result
  end
end
