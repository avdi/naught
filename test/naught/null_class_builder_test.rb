require "test_helper"
require "minitest/mock"

module Naught
  class NullClassBuilder
    module Commands
      class TestCommand
        def initialize(_builder, *_args)
        end

        def call
        end
      end
    end
  end
end

class NullClassBuilderTest < Minitest::Test
  def setup
    @builder = Naught::NullClassBuilder.new
  end

  def test_responds_to_commands_defined_in_null_object_builder_commands
    assert_respond_to @builder, :test_command
  end

  def test_returns_the_result_of_the_command_call
    test_command = Minitest::Mock.new
    test_command.expect(:call, "COMMAND RESULT")

    mock_new = ->(_builder, *_args) { test_command }

    Naught::NullClassBuilder::Commands::TestCommand.stub(:new, mock_new) do
      assert_equal "COMMAND RESULT", @builder.test_command("foo", 42)
    end

    test_command.verify
  end

  def test_does_not_respond_to_nonexistent_methods
    refute_respond_to @builder, :nonexistant_method
  end

  def test_raises_no_method_error_for_nonexistent_methods
    assert_raises(NoMethodError) { @builder.nonexistent_method }
  end

  def test_handles_method_names_that_would_create_invalid_constant_names
    refute_respond_to @builder, :"123invalid"
  end
end
