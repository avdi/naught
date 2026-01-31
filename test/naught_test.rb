require "test_helper"

module NaughtTestFixtures
  class Point
    attr_reader :x, :y
  end
end

TestNull = Naught.build unless defined?(TestNull)

class ImpersonationTest < Minitest::Test
  def setup
    @impersonation_class = Naught.build do |b|
      b.impersonate NaughtTestFixtures::Point
    end
    @null = @impersonation_class.new
  end

  def test_matches_the_impersonated_type
    assert_kind_of NaughtTestFixtures::Point, @null
  end

  def test_responds_to_x_method_from_the_impersonated_type
    assert_nil @null.x
  end

  def test_responds_to_y_method_from_the_impersonated_type
    assert_nil @null.y
  end

  def test_does_not_respond_to_unknown_methods
    assert_raises(NoMethodError) { @null.foo }
  end
end

class TraceableTest < Minitest::Test
  def setup
    @trace_null_class = Naught.build(&:traceable)
    @trace_null, @instantiation_line = @trace_null_class.new, __LINE__
  end

  def test_remembers_the_file_it_was_instantiated_from
    assert_equal __FILE__, @trace_null.__file__
  end

  def test_remembers_the_line_it_was_instantiated_from
    assert_equal @instantiation_line, @trace_null.__line__
  end

  def test_can_accept_custom_backtrace_info
    obj, line = make_null, __LINE__

    assert_equal line, obj.__line__
  end

  private

  def make_null
    @trace_null_class.get(caller: caller(1))
  end
end

class CustomizedNullObjectTest < Minitest::Test
  def setup
    @custom_null_class = Naught.build do |b|
      b.define_explicit_conversions
      define_method(:to_path) do
        File::NULL
      end

      define_method(:to_s) do
        "NOTHING TO SEE HERE"
      end
    end
    @custom_null = @custom_null_class.new
  end

  def test_responds_to_custom_defined_methods
    assert_equal File::NULL, @custom_null.to_path
  end

  def test_allows_generated_methods_to_be_overridden
    assert_equal "NOTHING TO SEE HERE", @custom_null.to_s
  end
end

class NamedNullObjectClassTest < Minitest::Test
  def test_has_named_ancestor_modules
    expected = [
      "TestNull",
      "TestNull::Customizations",
      "TestNull::GeneratedMethods"
    ]

    assert_equal expected, TestNull.ancestors[0..2].collect(&:name)
  end
end
