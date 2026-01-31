require "test_helper"
require "stringio"

module PebbleTestFixtures
  class Caller
    def call_method(thing)
      thing.info
    end

    def call_method_inside_block(thing)
      2.times.each { thing.info }
    end

    def call_method_inside_nested_block(thing)
      2.times.each { 2.times.each { thing.info } }
    end
  end
end

class PebbleTest < Minitest::Test
  def setup
    @test_output = StringIO.new
    output = @test_output
    @null_class = Naught.build do |b|
      b.pebble output
    end
    @null = @null_class.new
  end

  def test_prints_the_name_of_the_method_called
    @null.info

    assert_match(/^info\(\)/, @test_output.string)
  end

  def test_prints_the_arguments_received
    @null.info("foo", 5, :sym)

    assert_match(/^info\('foo', 5, :sym\)/, @test_output.string)
  end

  def test_prints_the_name_of_the_caller
    PebbleTestFixtures::Caller.new.call_method(@null)

    assert_match(/call_method$/, @test_output.string)
  end

  def test_returns_self
    assert_same @null, @null.info
  end
end

class PebbleBlockTest < Minitest::Test
  def setup
    @test_output = StringIO.new
    output = @test_output
    @null_class = Naught.build do |b|
      b.pebble output
    end
    @null = @null_class.new
  end

  def test_prints_the_indication_of_a_block
    PebbleTestFixtures::Caller.new.call_method_inside_block(@null)

    assert_match(/block/, @test_output.string)
  end

  def test_prints_the_name_of_the_method_that_has_the_block
    PebbleTestFixtures::Caller.new.call_method_inside_block(@null)

    assert_match(/call_method_inside_block$/, @test_output.string)
  end
end

class PebbleNestedBlockTest < Minitest::Test
  def setup
    @test_output = StringIO.new
    output = @test_output
    @null_class = Naught.build do |b|
      b.pebble output
    end
    @null = @null_class.new
  end

  def test_prints_the_indication_of_blocks_and_its_levels
    PebbleTestFixtures::Caller.new.call_method_inside_nested_block(@null)

    assert_match(/block \(2 levels\)/, @test_output.string)
  end

  def test_prints_the_name_of_the_method_that_has_the_block
    PebbleTestFixtures::Caller.new.call_method_inside_nested_block(@null)

    assert_match(/call_method_inside_nested_block$/, @test_output.string)
  end
end

class PebbleUnmatchedCallerTest < Minitest::Test
  def setup
    @test_output = StringIO.new
    output = @test_output
    @null_class = Naught.build do |b|
      b.pebble output
    end
    @null = @null_class.new
  end

  def test_prints_full_caller_info_when_format_unrecognized
    # Stub Kernel.caller to return an unrecognized format
    fake_caller = ["unusual format without method info"]

    Kernel.stub(:caller, ->(*) { fake_caller }) do
      @null.info
    end

    assert_match(/from unusual format without method info/, @test_output.string)
  end
end

class PebbleCallerStackTest < Minitest::Test
  def setup
    @test_output = StringIO.new
    output = @test_output
    @null_class = Naught.build do |b|
      b.pebble output
    end
    @null = @null_class.new
  end

  def test_calculates_block_levels_from_jruby_style_stack
    fake_stack = [
      "fake.rb:1:in `block in call_method_inside_nested_block'",
      "fake.rb:2:in `block in each'",
      "fake.rb:3:in `block in call_method_inside_nested_block'",
      "unusual format without method info",
      "fake.rb:4:in `call_method_inside_nested_block'"
    ]

    Kernel.stub(:caller, ->(*) { fake_stack }) do
      @null.info
    end

    assert_match(/block \(2 levels\) call_method_inside_nested_block$/, @test_output.string)
  end
end
