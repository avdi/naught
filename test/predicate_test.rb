require "test_helper"

module PredicateTestFixtures
  class Coffee
    attr_reader :origin

    def black?
    end
  end
end

class PredicateTest < Minitest::Test
  def setup
    @null_class = Naught.build do |config|
      config.predicates_return false
    end
    @null = @null_class.new
  end

  def test_responds_to_predicate_style_methods_with_false
    refute_predicate @null, :too_much_coffee?
  end

  def test_responds_to_other_methods_with_nil
    assert_nil @null.foobar
  end

  def test_reports_responding_to_predicate_methods
    assert_respond_to @null, :too_much_coffee?
  end
end

class PredicateBlackHoleTest < Minitest::Test
  def setup
    @null_class = Naught.build do |config|
      config.black_hole
      config.predicates_return false
    end
    @null = @null_class.new
  end

  def test_responds_to_predicate_style_methods_with_false
    refute_predicate @null, :too_much_coffee?
  end

  def test_responds_to_other_methods_with_self
    assert_same @null, @null.foobar
  end
end

class PredicateBlackHoleReverseOrderTest < Minitest::Test
  def setup
    @null_class = Naught.build do |config|
      config.predicates_return false
      config.black_hole
    end
    @null = @null_class.new
  end

  def test_responds_to_predicate_style_methods_with_false
    refute_predicate @null, :too_much_coffee?
  end

  def test_responds_to_other_methods_with_self
    assert_same @null, @null.foobar
  end
end

class PredicateMimicTest < Minitest::Test
  def setup
    @null_class = Naught.build do |config|
      config.mimic PredicateTestFixtures::Coffee
      config.predicates_return false
    end
    @null = @null_class.new
  end

  def test_responds_to_predicate_style_methods_with_false
    refute_predicate @null, :black?
  end

  def test_responds_to_other_methods_with_nil
    assert_nil @null.origin
  end

  def test_does_not_respond_to_undefined_methods
    refute_respond_to @null, :leaf_variety
  end

  def test_raises_no_method_error_for_undefined_methods
    assert_raises(NoMethodError) { @null.leaf_variety }
  end
end
