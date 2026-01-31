require "test_helper"

module CallstackTestHelper
  def build_callstack_null
    build_null(&:callstack)
  end
end

class CallLocationAttributesTest < NaughtTestCase
  include CallLocationHelper

  def test_stores_method_name_as_label
    assert_equal "foo", make_location.label
  end

  def test_converts_symbol_label_to_string
    assert_equal "foo", make_location(label: :foo).label
  end

  def test_stores_arguments
    assert_equal [1, "hello", :sym], make_location(args: [1, "hello", :sym]).args
  end

  def test_freezes_arguments
    args = [1, 2, 3]
    location = make_location(args: args)

    assert_predicate location.args, :frozen?
    args << 4

    assert_equal [1, 2, 3], location.args
  end

  def test_stores_path
    assert_equal "/path/to/file.rb", make_location.path
  end

  def test_absolute_path_is_alias_for_path
    location = make_location

    assert_equal location.path, location.absolute_path
  end

  def test_stores_lineno
    assert_equal 42, make_location.lineno
  end

  def test_stores_base_label
    assert_equal "method", make_location.base_label
  end
end

class CallLocationFormattingTest < NaughtTestCase
  include CallLocationHelper

  def test_to_s_with_base_label
    location = make_location(args: [1, "bar"], base_label: "some_method")

    assert_equal "/path/to/file.rb:42:in `some_method' -> foo(1, \"bar\")", location.to_s
  end

  def test_to_s_without_base_label
    location = make_location(args: [], base_label: nil)

    assert_equal "/path/to/file.rb:42 -> foo()", location.to_s
  end

  def test_inspect_includes_class_name
    assert_match(/^#<Naught::CallLocation /, make_location.inspect)
  end
end

class CallLocationEqualityTest < NaughtTestCase
  include CallLocationHelper

  def test_equal_locations_are_equal
    assert_equal make_location, make_location
  end

  def test_eql_returns_true_for_equal_locations
    assert make_location.eql?(make_location)
  end

  def test_equal_locations_have_same_hash
    assert_equal make_location.hash, make_location.hash
  end

  def test_different_label_means_not_equal
    refute_equal make_location, make_location(label: :bar)
  end

  def test_different_args_means_not_equal
    refute_equal make_location, make_location(args: [2])
  end

  def test_different_path_means_not_equal
    refute_equal make_location, make_location(path: "/other.rb")
  end

  def test_different_lineno_means_not_equal
    refute_equal make_location, make_location(lineno: 99)
  end

  def test_different_base_label_means_not_equal
    refute_equal make_location, make_location(base_label: "other")
  end

  def test_not_equal_to_non_call_location
    refute_equal make_location, "not a call location"
  end

  def test_not_equal_to_nil
    refute_equal make_location, nil
  end
end

class CallstackBasicTest < NaughtTestCase
  include CallstackTestHelper

  def setup
    @null_class, @null = build_callstack_null
  end

  def test_provides_call_trace_accessor
    assert_respond_to @null, :__call_trace__
  end

  def test_call_trace_starts_empty
    assert_empty @null.__call_trace__
  end

  def test_records_single_method_call
    @null.foo

    assert_equal 1, @null.__call_trace__.size
    assert_equal 1, @null.__call_trace__[0].size
    assert_equal "foo", @null.__call_trace__[0][0].label
  end

  def test_records_method_arguments
    @null.foo(1, "hello", :sym)

    assert_equal [1, "hello", :sym], @null.__call_trace__[0][0].args
  end

  def test_records_source_location
    @null.foo
    line = __LINE__ - 1

    location = @null.__call_trace__[0][0]

    assert_equal __FILE__, location.path
    assert_equal line, location.lineno
  end

  def test_returns_chainable_object
    result = @null.foo
    # Returns a chain proxy that allows further chaining
    assert_respond_to result, :bar
  end
end

class CallstackChainingTest < NaughtTestCase
  include CallstackTestHelper

  def setup
    @null_class, @null = build_callstack_null
  end

  def test_chained_calls_appear_in_same_trace
    @null.foo.bar.baz

    assert_equal 1, @null.__call_trace__.size

    trace = @null.__call_trace__[0]

    assert_equal 3, trace.size
    assert_equal %w[foo bar baz], trace.map(&:label)
  end

  def test_separate_calls_create_separate_traces
    @null.foo.bar
    @null.baz.buz

    assert_equal 2, @null.__call_trace__.size
    assert_equal %w[foo bar], @null.__call_trace__[0].map(&:label)
    assert_equal %w[baz buz], @null.__call_trace__[1].map(&:label)
  end

  def test_mixed_chained_and_separate_calls_creates_correct_number_of_traces
    @null.a
    @null.b.c
    @null.d

    assert_equal 3, @null.__call_trace__.size
  end

  def test_mixed_chained_and_separate_calls_records_correct_methods
    @null.a
    @null.b.c
    @null.d

    assert_equal ["a"], @null.__call_trace__[0].map(&:label)
    assert_equal %w[b c], @null.__call_trace__[1].map(&:label)
    assert_equal ["d"], @null.__call_trace__[2].map(&:label)
  end
end

class CallstackMultipleInstancesTest < NaughtTestCase
  include CallstackTestHelper

  def setup
    @null_class, = build_callstack_null
  end

  def test_first_instance_has_its_own_trace
    null1 = @null_class.new
    null2 = @null_class.new

    null1.foo.bar
    null2.baz.buz

    assert_equal 1, null1.__call_trace__.size
    assert_equal %w[foo bar], null1.__call_trace__[0].map(&:label)
  end

  def test_second_instance_has_its_own_trace
    null1 = @null_class.new
    null2 = @null_class.new

    null1.foo.bar
    null2.baz.buz

    assert_equal 1, null2.__call_trace__.size
    assert_equal %w[baz buz], null2.__call_trace__[0].map(&:label)
  end
end

class CallstackCallerInfoTest < NaughtTestCase
  include CallstackTestHelper

  def setup
    @null_class, @null = build_callstack_null
  end

  def test_records_base_label_from_caller
    call_from_method
    location = @null.__call_trace__[0][0]

    assert_equal "call_from_method", location.base_label
  end

  private

  def call_from_method
    @null.foo
  end
end

class CallstackChainProxyTest < NaughtTestCase
  include CallstackTestHelper

  def setup
    @null_class, @null = build_callstack_null
  end

  def test_chain_proxy_responds_to_any_method
    chain = @null.foo

    assert_respond_to chain, :bar
    assert_respond_to chain, :anything_at_all
    assert_respond_to chain, :some_method
  end

  def test_chain_proxy_inspect
    chain = @null.foo

    assert_equal "<null:chain>", chain.inspect
  end

  def test_chain_proxy_class_returns_null_class
    chain = @null.foo

    assert_equal @null_class, chain.class
  end
end

class CallstackUnusualCallerTest < NaughtTestCase
  include CallstackTestHelper

  def setup
    @null_class, @null = build_callstack_null
  end

  def test_handles_caller_without_method_signature
    # Stub Kernel.caller to return a format without method info
    fake_caller = ["unusual_format.rb:10"]

    Kernel.stub(:caller, ->(*) { [fake_caller.first] }) do
      @null.foo
    end
    location = @null.__call_trace__[0][0]

    assert_equal "unusual_format.rb", location.path
    assert_equal 10, location.lineno
    assert_nil location.base_label
  end

  def test_chain_proxy_handles_caller_without_method_signature
    # First call to get the chain proxy
    chain = @null.foo

    # Stub Kernel.caller for the chained call
    fake_caller = ["unusual_format.rb:20"]

    Kernel.stub(:caller, ->(*) { [fake_caller.first] }) do
      chain.bar
    end
    location = @null.__call_trace__[0][1]

    assert_equal "unusual_format.rb", location.path
    assert_equal 20, location.lineno
    assert_nil location.base_label
  end

  def test_handles_caller_with_method_part_but_no_quotes
    # Stub Kernel.caller to return a format with method part but no quoted method name
    fake_caller = ["file.rb:10:no quotes here"]

    Kernel.stub(:caller, ->(*) { [fake_caller.first] }) do
      @null.foo
    end
    location = @null.__call_trace__[0][0]

    assert_nil location.base_label
  end

  def test_chain_proxy_handles_caller_with_method_part_but_no_quotes
    chain = @null.foo
    fake_caller = ["file.rb:20:no quotes here"]

    Kernel.stub(:caller, ->(*) { [fake_caller.first] }) do
      chain.bar
    end
    location = @null.__call_trace__[0][1]

    assert_nil location.base_label
  end
end

class CallstackRespondToTest < NaughtTestCase
  include CallstackTestHelper

  def setup
    @null_class, @null = build_callstack_null
  end

  def test_respond_to_call_trace
    assert_respond_to @null, :__call_trace__
  end

  def test_respond_to_delegates_to_super_for_other_methods
    # respond_to? should delegate to super for methods other than __call_trace__
    # Since this null object responds to any message, this should return true
    assert_respond_to @null, :some_random_method
  end
end

class CallstackWithTraceableTest < NaughtTestCase
  def setup
    @null_class = build_null_class { |b|
      b.callstack
      b.traceable
    }
    @null = @null_class.new
    @line = __LINE__ - 1
  end

  def test_records_file
    @null.foo.bar

    assert_equal __FILE__, @null.__file__
  end

  def test_records_line
    assert_equal @line, @null.__line__
  end

  def test_callstack_still_works
    @null.foo.bar

    assert_equal 1, @null.__call_trace__.size
    assert_equal %w[foo bar], @null.__call_trace__[0].map(&:label)
  end
end

class CallstackWithPredicatesReturnTest < NaughtTestCase
  def setup
    @null_class, @null = build_null { |b|
      b.callstack
      b.predicates_return false
    }
  end

  def test_predicate_calls_are_not_recorded
    # predicates_return's method_missing intercepts these and returns
    # without calling super, so predicate calls are NOT recorded
    refute_predicate @null, :valid?
    @null.foo.bar

    assert_equal 1, @null.__call_trace__.size
    assert_equal %w[foo bar], @null.__call_trace__[0].map(&:label)
  end
end
