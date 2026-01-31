require "test_helper"
require "stringio"

module PebbleTestSetup
  def setup
    @output = StringIO.new
    output = @output
    _, @null = build_null { |b| b.pebble output }
    @caller = NaughtTestFixtures::Caller.new
  end
end

class PebbleBasicTest < NaughtTestCase
  include PebbleTestSetup

  def test_prints_method_name
    @null.info

    assert_match(/^info\(\)/, @output.string)
  end

  def test_prints_arguments
    @null.info("foo", 5, :sym)

    assert_match(/^info\('foo', 5, :sym\)/, @output.string)
  end

  def test_prints_caller_name
    @caller.call_method(@null)

    assert_match(/call_method$/, @output.string)
  end

  def test_returns_self
    assert_same @null, @null.info
  end
end

class PebbleBlockTest < NaughtTestCase
  include PebbleTestSetup

  def test_prints_block_and_method_info
    @caller.call_method_inside_block(@null)

    assert_match(/block/, @output.string)
    assert_match(/call_method_inside_block$/, @output.string)
  end

  def test_prints_nested_block_levels
    @caller.call_method_inside_nested_block(@null)

    assert_match(/block \(2 levels\)/, @output.string)
    assert_match(/call_method_inside_nested_block$/, @output.string)
  end
end

class PebbleEdgeCasesTest < NaughtTestCase
  include PebbleTestSetup

  def test_prints_full_caller_when_format_unrecognized
    Kernel.stub(:caller, ->(*) { ["unusual format without method info"] }) do
      @null.info
    end

    assert_match(/from unusual format without method info/, @output.string)
  end

  def test_calculates_block_levels_from_jruby_style_stack
    fake_stack = [
      "fake.rb:1:in `block in call_method_inside_nested_block'",
      "fake.rb:2:in `block in each'",
      "fake.rb:3:in `block in call_method_inside_nested_block'",
      "unusual format without method info",
      "fake.rb:4:in `call_method_inside_nested_block'"
    ]
    Kernel.stub(:caller, ->(*) { fake_stack }) { @null.info }

    assert_match(/block \(2 levels\) call_method_inside_nested_block$/, @output.string)
  end
end
