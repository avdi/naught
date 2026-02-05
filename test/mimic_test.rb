require "test_helper"
require "logger"

# Shared assertions for mimic + black_hole combinations
module MimicBlackHoleAssertions
  def test_returns_self_from_info_method
    assert_returns_self @null, :info
  end

  def test_returns_self_from_error_method
    assert_returns_self @null, :error
  end

  def test_returns_self_from_shift_method
    assert_same @null, @null << "test"
  end

  def test_does_not_respond_to_undefined_methods
    assert_raises(NoMethodError) { @null.foobar }
  end
end

class MimicTest < NaughtTestCase
  def setup
    @mimic_class = build_null_class { |b| b.mimic NaughtTestFixtures::LibraryPatron }
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
    assert_equal "<null:NaughtTestFixtures::LibraryPatron>", @null.inspect
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

class MimicWithoutSuperTest < NaughtTestCase
  def setup
    @mimic_class = build_null_class { |b| b.mimic NaughtTestFixtures::LibraryPatron, include_super: false }
    @null = @mimic_class.new
  end

  def test_excludes_inherited_method_authorized_for
    refute_respond_to @null, :authorized_for?
  end

  def test_excludes_inherited_method_login
    refute_respond_to @null, :login
  end
end

class MimicWithExampleTest < NaughtTestCase
  def setup
    milton = NaughtTestFixtures::LibraryPatron.new
    def milton.stapler
    end
    @mimic_class = build_null_class { |b| b.mimic example: milton }
    @null = @mimic_class.new
  end

  def test_responds_to_method_defined_only_on_the_example_instance
    assert_respond_to @null, :stapler
  end

  def test_responds_to_method_defined_on_the_class_of_the_instance
    assert_respond_to @null, :member?
  end
end

class MimicBasicObjectSubclassTest < NaughtTestCase
  def setup
    @mimic_class = build_null_class { |b| b.mimic NaughtTestFixtures::BasicWidget }
    @null = @mimic_class.new
  end

  def test_uses_basic_object_as_base_class_and_responds_to_mimicked_methods
    assert_nil @null.widget_method
  end
end

class MimicWithBlackHoleTest < NaughtTestCase
  include MimicBlackHoleAssertions

  def setup
    _, @null = build_null { |b|
      b.mimic Logger
      b.black_hole
    }
  end
end

class MimicWithBlackHoleReverseOrderTest < NaughtTestCase
  include MimicBlackHoleAssertions

  def setup
    _, @null = build_null { |b|
      b.black_hole
      b.mimic Logger
    }
  end
end

# Test for GitHub issue #55: Composing black_hole, predicates_return and impersonate
# https://github.com/avdi/naught/issues/55
class MimicDoesNotStubMethodMissingTest < NaughtTestCase
  def setup
    @mimic_class = build_null_class { |b| b.mimic NaughtTestFixtures::DynamicClass }
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

class MimicWithPredicatesReturnAndMethodMissingTest < NaughtTestCase
  def setup
    @mimic_class = build_null_class { |b|
      b.mimic NaughtTestFixtures::DynamicClass
      b.predicates_return false
    }
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

class MimicWithBlackHoleAndPredicatesReturnTest < NaughtTestCase
  def setup
    @mimic_class = build_null_class { |b|
      b.mimic NaughtTestFixtures::DynamicClass
      b.black_hole
      b.predicates_return false
    }
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

class ImpersonateWithBlackHoleAndPredicatesReturnTest < NaughtTestCase
  def setup
    @impersonate_class = build_null_class { |b|
      b.impersonate NaughtTestFixtures::DynamicClass
      b.black_hole
      b.predicates_return false
    }
    @null = @impersonate_class.new
  end

  def test_predicates_return_false
    refute_predicate @null, :active?
  end

  def test_regular_mimicked_methods_return_self
    assert_same @null, @null.regular_method
  end

  def test_is_a_dynamic_class
    assert_kind_of NaughtTestFixtures::DynamicClass, @null
  end

  def test_undefined_methods_raise_error
    assert_raises(NoMethodError) { @null.foobar }
  end
end

# Test for GitHub issue #78: mimic() with include_dynamic option
# https://github.com/avdi/naught/issues/78
class MimicWithIncludeDynamicTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::StripeStyleObject.new(
      id: "inv_123",
      amount: 1000,
      period_end: Time.now.to_i
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example, include_dynamic: true
    }
    @null = @mimic_class.new
  end

  def test_responds_to_dynamic_method
    assert_respond_to @null, :period_end
  end

  def test_dynamic_method_returns_nil
    assert_nil @null.period_end
  end

  def test_responds_to_all_dynamic_methods
    assert_respond_to @null, :id
    assert_respond_to @null, :amount
    assert_respond_to @null, :period_end
  end

  def test_responds_to_regular_method
    assert_respond_to @null, :regular_method
  end

  def test_does_not_respond_to_undefined_methods
    refute_respond_to @null, :undefined_attribute
  end

  def test_raises_for_undefined_methods
    assert_raises(NoMethodError) { @null.undefined_attribute }
  end
end

class MimicWithIncludeDynamicAndBlackHoleTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::StripeStyleObject.new(
      id: "inv_123",
      customer: "cus_456"
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example, include_dynamic: true
      b.black_hole
    }
    @null = @mimic_class.new
  end

  def test_dynamic_method_returns_self
    assert_same @null, @null.id
  end

  def test_regular_method_returns_self
    assert_same @null, @null.regular_method
  end

  def test_undefined_methods_raise_error
    assert_raises(NoMethodError) { @null.undefined_attribute }
  end
end

class MimicWithExampleIncludesDynamicByDefaultTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::StripeStyleObject.new(
      id: "inv_123",
      period_end: Time.now.to_i
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example
    }
    @null = @mimic_class.new
  end

  def test_responds_to_dynamic_method_by_default_with_example
    assert_respond_to @null, :period_end
  end

  def test_responds_to_regular_method
    assert_respond_to @null, :regular_method
  end
end

class MimicWithExampleExplicitlyDisabledDynamicTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::StripeStyleObject.new(
      id: "inv_123",
      period_end: Time.now.to_i
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example, include_dynamic: false
    }
    @null = @mimic_class.new
  end

  def test_does_not_respond_to_dynamic_method_when_explicitly_disabled
    refute_respond_to @null, :period_end
  end

  def test_responds_to_regular_method
    assert_respond_to @null, :regular_method
  end
end

class MimicWithIncludeDynamicActiveRecordStyleTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::ActiveRecordStyleObject.new(
      name: "John",
      email: "john@example.com"
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example, include_dynamic: true
    }
    @null = @mimic_class.new
  end

  def test_responds_to_dynamic_methods_via_attribute_names
    assert_respond_to @null, :name
    assert_respond_to @null, :email
  end

  def test_dynamic_methods_return_nil
    assert_nil @null.name
    assert_nil @null.email
  end

  def test_responds_to_regular_method
    assert_respond_to @null, :regular_method
  end
end

class MimicWithIncludeDynamicOpenStructStyleTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::OpenStructStyleObject.new(
      foo: "bar",
      baz: 123
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example, include_dynamic: true
    }
    @null = @mimic_class.new
  end

  def test_responds_to_dynamic_methods_via_to_h
    assert_respond_to @null, :foo
    assert_respond_to @null, :baz
  end

  def test_dynamic_methods_return_nil
    assert_nil @null.foo
    assert_nil @null.baz
  end

  def test_responds_to_regular_method
    assert_respond_to @null, :regular_method
  end
end

class MimicWithIncludeDynamicBrokenToHTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::BrokenToHObject.new(
      foo: "bar"
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example, include_dynamic: true
    }
    @null = @mimic_class.new
  end

  def test_handles_broken_to_h_gracefully
    # Should not raise an error when building
    assert_respond_to @null, :regular_method
  end

  def test_does_not_respond_to_dynamic_methods_when_to_h_fails
    # Since to_h raises and there's no keys/attribute_names, no dynamic methods found
    refute_respond_to @null, :foo
  end
end

class MimicWithIncludeDynamicClassBasedTest < NaughtTestCase
  def setup
    # Test include_dynamic with class-based mimic (no example instance)
    @mimic_class = build_null_class { |b|
      b.mimic NaughtTestFixtures::StripeStyleObject, include_dynamic: true
    }
    @null = @mimic_class.new
  end

  def test_responds_to_regular_methods
    assert_respond_to @null, :regular_method
  end

  def test_does_not_have_dynamic_methods_without_example
    # Without an example instance, we can't discover dynamic methods
    assert_nil @null.regular_method
  end
end

class MimicWithIncludeDynamicNonHashToHTest < NaughtTestCase
  def setup
    example = NaughtTestFixtures::NonHashToHObject.new(
      foo: "bar"
    )
    @mimic_class = build_null_class { |b|
      b.mimic example: example, include_dynamic: true
    }
    @null = @mimic_class.new
  end

  def test_handles_non_hash_to_h_gracefully
    # Should not raise an error when building
    assert_respond_to @null, :regular_method
  end

  def test_does_not_respond_to_dynamic_methods_when_to_h_returns_non_hash
    # Since to_h returns an Array and there's no keys/attribute_names, no dynamic methods found
    refute_respond_to @null, :foo
  end
end
