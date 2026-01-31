require "test_helper"

class NullClassBuilderCommandTest < Minitest::Test
  def test_is_abstract
    command = Naught::NullClassBuilder::Command.new(nil)
    assert_raises(NotImplementedError) { command.call }
  end
end
