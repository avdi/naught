require "test_helper"
require "logger"

module MimicTestFixtures
  class User
    attr_reader :login
  end

  module Authorizable
    def authorized_for?(_)
    end
  end

  class LibraryPatron < User
    include Authorizable

    attr_reader :name

    def member?
    end

    def notify_of_overdue_books(_)
    end
  end

  class BasicWidget < BasicObject
    def widget_method
    end
  end
end

class MimicTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.mimic MimicTestFixtures::LibraryPatron
    end
    @null = @mimic_class.new
  end

  def test_responds_to_member_method
    assert_nil @null.member?
  end

  def test_responds_to_name_method
    assert_nil @null.name
  end

  def test_responds_to_notify_of_overdue_books_method
    assert_nil @null.notify_of_overdue_books(["The Grapes of Wrath"])
  end

  def test_does_not_respond_to_methods_not_defined_on_the_target_class
    assert_raises(NoMethodError) { @null.foobar }
  end

  def test_reports_it_responds_to_member
    assert_respond_to @null, :member?
  end

  def test_reports_it_responds_to_name
    assert_respond_to @null, :name
  end

  def test_reports_it_responds_to_notify_of_overdue_books
    assert_respond_to @null, :notify_of_overdue_books
  end

  def test_reports_it_does_not_respond_to_foobar
    refute_respond_to @null, :foobar
  end

  def test_has_an_informative_inspect_string
    assert_equal "<null:MimicTestFixtures::LibraryPatron>", @null.inspect
  end

  def test_does_not_mimic_object_id_from_object
    refute_nil @null.object_id
  end

  def test_does_not_mimic_hash_from_object
    refute_nil @null.hash
  end

  def test_includes_inherited_method_authorized_for
    assert_nil @null.authorized_for?("something")
  end

  def test_includes_inherited_method_login
    assert_nil @null.login
  end
end

class MimicWithoutSuperTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.mimic MimicTestFixtures::LibraryPatron, include_super: false
    end
    @null = @mimic_class.new
  end

  def test_excludes_inherited_method_authorized_for
    refute_respond_to @null, :authorized_for?
  end

  def test_excludes_inherited_method_login
    refute_respond_to @null, :login
  end
end

class MimicWithExampleTest < Minitest::Test
  def setup
    milton = MimicTestFixtures::LibraryPatron.new
    def milton.stapler
    end
    @mimic_class = Naught.build do |b|
      b.mimic example: milton
    end
    @null = @mimic_class.new
  end

  def test_responds_to_method_defined_only_on_the_example_instance
    assert_respond_to @null, :stapler
  end

  def test_responds_to_method_defined_on_the_class_of_the_instance
    assert_respond_to @null, :member?
  end
end

class MimicBasicObjectSubclassTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.mimic MimicTestFixtures::BasicWidget
    end
    @null = @mimic_class.new
  end

  def test_uses_basic_object_as_base_class_and_responds_to_mimicked_methods
    assert_nil @null.widget_method
  end
end

class MimicWithBlackHoleTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.mimic Logger
      b.black_hole
    end
    @null = @mimic_class.new
  end

  def test_returns_self_from_info_method
    assert_same @null, @null.info
  end

  def test_returns_self_from_error_method
    assert_same @null, @null.error
  end

  def test_returns_self_from_shift_method
    assert_same @null, @null << "test"
  end

  def test_does_not_respond_to_methods_not_defined_on_the_target_class
    assert_raises(NoMethodError) { @null.foobar }
  end
end

class MimicWithBlackHoleReverseOrderTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.black_hole
      b.mimic Logger
    end
    @null = @mimic_class.new
  end

  def test_returns_self_from_info_method
    assert_same @null, @null.info
  end

  def test_returns_self_from_error_method
    assert_same @null, @null.error
  end

  def test_returns_self_from_shift_method
    assert_same @null, @null << "test"
  end

  def test_does_not_respond_to_methods_not_defined_on_the_target_class
    assert_raises(NoMethodError) { @null.foobar }
  end
end

# Test for GitHub issue #55: Composing black_hole, predicates_return and impersonate
# https://github.com/avdi/naught/issues/55
module MimicMethodMissingTestFixtures
  # A class that defines method_missing, similar to ActiveRecord models
  class DynamicClass
    def regular_method
      "regular"
    end

    def active?
      true
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s.start_with?("dynamic_")
        "dynamic: #{method_name}"
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?("dynamic_") || super
    end
  end
end

class MimicDoesNotStubMethodMissingTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.mimic MimicMethodMissingTestFixtures::DynamicClass
    end
    @null = @mimic_class.new
  end

  def test_stubs_regular_methods
    assert_nil @null.regular_method
  end

  def test_stubs_predicate_methods
    assert_nil @null.active?
  end

  def test_does_not_respond_to_dynamic_methods
    # The null class should not mimic the dynamic method behavior
    refute_respond_to @null, :dynamic_foo
  end

  def test_raises_for_undefined_methods
    assert_raises(NoMethodError) { @null.undefined_method }
  end
end

class MimicWithPredicatesReturnAndMethodMissingTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.mimic MimicMethodMissingTestFixtures::DynamicClass
      b.predicates_return false
    end
    @null = @mimic_class.new
  end

  def test_predicates_return_false_for_mimicked_predicates
    refute_predicate @null, :active?
  end

  def test_predicates_return_false_for_any_predicate
    refute_predicate @null, :something?
  end

  def test_regular_methods_return_nil
    assert_nil @null.regular_method
  end
end

class MimicWithBlackHoleAndPredicatesReturnTest < Minitest::Test
  def setup
    @mimic_class = Naught.build do |b|
      b.mimic MimicMethodMissingTestFixtures::DynamicClass
      b.black_hole
      b.predicates_return false
    end
    @null = @mimic_class.new
  end

  def test_predicates_return_false
    refute_predicate @null, :active?
  end

  def test_regular_mimicked_methods_return_self
    assert_same @null, @null.regular_method
  end

  def test_undefined_methods_raise_error
    assert_raises(NoMethodError) { @null.foobar }
  end
end

class ImpersonateWithBlackHoleAndPredicatesReturnTest < Minitest::Test
  def setup
    @impersonate_class = Naught.build do |b|
      b.impersonate MimicMethodMissingTestFixtures::DynamicClass
      b.black_hole
      b.predicates_return false
    end
    @null = @impersonate_class.new
  end

  def test_predicates_return_false
    refute_predicate @null, :active?
  end

  def test_regular_mimicked_methods_return_self
    assert_same @null, @null.regular_method
  end

  def test_is_a_dynamic_class
    assert_kind_of MimicMethodMissingTestFixtures::DynamicClass, @null
  end

  def test_undefined_methods_raise_error
    assert_raises(NoMethodError) { @null.foobar }
  end
end
