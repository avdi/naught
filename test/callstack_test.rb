require "test_helper"

class CallLocationTest < Minitest::Test
  def test_stores_method_name_as_label
    location = Naught::CallLocation.new(
      label: :foo,
      args: [],
      path: "/path/to/file.rb",
      lineno: 42
    )

    assert_equal "foo", location.label
  end

  def test_stores_arguments
    location = Naught::CallLocation.new(
      label: :foo,
      args: [1, "hello", :sym],
      path: "/path/to/file.rb",
      lineno: 42
    )

    assert_equal [1, "hello", :sym], location.args
  end

  def test_freezes_arguments
    args = [1, 2, 3]
    location = Naught::CallLocation.new(
      label: :foo,
      args: args,
      path: "/path/to/file.rb",
      lineno: 42
    )

    assert_predicate location.args, :frozen?

    # Original array should not be modified
    args << 4

    assert_equal [1, 2, 3], location.args
  end

  def test_stores_path
    location = Naught::CallLocation.new(
      label: :foo,
      args: [],
      path: "/path/to/file.rb",
      lineno: 42
    )

    assert_equal "/path/to/file.rb", location.path
    assert_equal "/path/to/file.rb", location.absolute_path
  end

  def test_stores_lineno
    location = Naught::CallLocation.new(
      label: :foo,
      args: [],
      path: "/path/to/file.rb",
      lineno: 42
    )

    assert_equal 42, location.lineno
  end

  def test_stores_base_label
    location = Naught::CallLocation.new(
      label: :foo,
      args: [],
      path: "/path/to/file.rb",
      lineno: 42,
      base_label: "some_method"
    )

    assert_equal "some_method", location.base_label
  end

  def test_to_s_with_base_label
    location = Naught::CallLocation.new(
      label: :foo,
      args: [1, "bar"],
      path: "/path/to/file.rb",
      lineno: 42,
      base_label: "some_method"
    )

    assert_equal "/path/to/file.rb:42:in `some_method' -> foo(1, \"bar\")", location.to_s
  end

  def test_to_s_without_base_label
    location = Naught::CallLocation.new(
      label: :foo,
      args: [],
      path: "/path/to/file.rb",
      lineno: 42
    )

    assert_equal "/path/to/file.rb:42 -> foo()", location.to_s
  end

  def test_inspect
    location = Naught::CallLocation.new(
      label: :foo,
      args: [],
      path: "/path/to/file.rb",
      lineno: 42
    )

    assert_match(/^#<Naught::CallLocation /, location.inspect)
  end

  def test_equality
    location1 = Naught::CallLocation.new(
      label: :foo,
      args: [1],
      path: "/path/to/file.rb",
      lineno: 42,
      base_label: "method"
    )

    location2 = Naught::CallLocation.new(
      label: :foo,
      args: [1],
      path: "/path/to/file.rb",
      lineno: 42,
      base_label: "method"
    )

    assert_equal location1, location2
    assert location1.eql?(location2)
    assert_equal location1.hash, location2.hash
  end

  def test_inequality_with_different_label
    location1 = make_location
    location2 = make_location(label: :bar)

    refute_equal location1, location2
  end

  def test_inequality_with_different_args
    location1 = make_location
    location2 = make_location(args: [2])

    refute_equal location1, location2
  end

  def test_inequality_with_different_path
    location1 = make_location
    location2 = make_location(path: "/other.rb")

    refute_equal location1, location2
  end

  def test_inequality_with_different_lineno
    location1 = make_location
    location2 = make_location(lineno: 99)

    refute_equal location1, location2
  end

  def test_inequality_with_different_base_label
    location1 = make_location
    location2 = make_location(base_label: "other")

    refute_equal location1, location2
  end

  def test_not_equal_to_non_call_location
    location = Naught::CallLocation.new(
      label: :foo,
      args: [],
      path: "/path/to/file.rb",
      lineno: 42
    )

    refute_equal location, "not a call location"
    refute_equal location, nil
  end

  private

  def make_location(overrides = {})
    defaults = {
      label: :foo,
      args: [1],
      path: "/path/to/file.rb",
      lineno: 42,
      base_label: "method"
    }
    Naught::CallLocation.new(**defaults.merge(overrides))
  end
end

class CallstackBasicTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:callstack)
    @null = @null_class.new
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

class CallstackChainingTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:callstack)
    @null = @null_class.new
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

class CallstackMultipleInstancesTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:callstack)
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

class CallstackCallerInfoTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:callstack)
    @null = @null_class.new
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

class CallstackChainProxyTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:callstack)
    @null = @null_class.new
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

class CallstackUnusualCallerTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:callstack)
    @null = @null_class.new
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

class CallstackRespondToTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:callstack)
    @null = @null_class.new
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

class CallstackIntegrationTest < Minitest::Test
  def test_traceable_records_file_when_combined_with_callstack
    null_class = Naught.build do |b|
      b.callstack
      b.traceable
    end

    null = null_class.new
    null.foo.bar

    assert_equal __FILE__, null.__file__
  end

  def test_traceable_records_line_when_combined_with_callstack
    null_class = Naught.build do |b|
      b.callstack
      b.traceable
    end

    null = null_class.new
    line = __LINE__ - 1
    null.foo.bar

    assert_equal line, null.__line__
  end

  def test_callstack_works_when_combined_with_traceable
    null_class = Naught.build do |b|
      b.callstack
      b.traceable
    end

    null = null_class.new
    null.foo.bar

    assert_equal 1, null.__call_trace__.size
    assert_equal %w[foo bar], null.__call_trace__[0].map(&:label)
  end

  def test_works_with_predicates_return
    null_class = Naught.build do |b|
      b.callstack
      b.predicates_return false
    end

    null = null_class.new

    # predicates_return makes predicate methods return false
    # predicates_return's method_missing intercepts these and returns
    # without calling super, so predicate calls are NOT recorded
    refute_predicate null, :valid?
    null.foo.bar

    # Only foo.bar is recorded, not valid? (which was handled by predicates_return)
    assert_equal 1, null.__call_trace__.size
    assert_equal %w[foo bar], null.__call_trace__[0].map(&:label)
  end
end
