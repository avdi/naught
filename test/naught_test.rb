require "test_helper"

class ImpersonationTest < NaughtTestCase
  def setup
    @null_class = Naught.build { |b| b.impersonate NaughtTestFixtures::Point }
    @null = @null_class.new
  end

  def test_matches_the_impersonated_type
    assert_kind_of NaughtTestFixtures::Point, @null
  end

  def test_responds_to_methods_from_impersonated_type
    assert_nil @null.x
    assert_nil @null.y
  end

  def test_does_not_respond_to_unknown_methods
    assert_raises(NoMethodError) { @null.foo }
  end
end

class TraceableTest < NaughtTestCase
  def setup
    @null_class = Naught.build(&:traceable)
    @null = @null_class.new
    @line = __LINE__ - 1
  end

  def test_remembers_file
    assert_equal __FILE__, @null.__file__
  end

  def test_remembers_line
    assert_equal @line, @null.__line__
  end

  def test_accepts_custom_backtrace
    obj = @null_class.get(caller: caller(0))

    assert_equal __LINE__ - 2, obj.__line__
  end
end

class CustomizedNullObjectTest < NaughtTestCase
  def setup
    @null_class = Naught.build do |b|
      b.define_explicit_conversions
      define_method(:to_path) { File::NULL }
      define_method(:to_s) { "NOTHING TO SEE HERE" }
    end
    @null = @null_class.new
  end

  def test_responds_to_custom_methods
    assert_equal File::NULL, @null.to_path
  end

  def test_can_override_generated_methods
    assert_equal "NOTHING TO SEE HERE", @null.to_s
  end
end

class NamedNullObjectClassTest < NaughtTestCase
  # Tests that assigning a null class to a constant gives it a proper name
  NamedNull = Naught.build

  def test_has_named_ancestor_modules
    expected = [
      "NamedNullObjectClassTest::NamedNull",
      "NamedNullObjectClassTest::NamedNull::Customizations",
      "NamedNullObjectClassTest::NamedNull::GeneratedMethods"
    ]

    assert_equal expected, NamedNull.ancestors[0..2].map(&:name)
  end
end
