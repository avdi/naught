require "test_helper"

class BasicNullObjectTest < Minitest::Test
  def setup
    @null_class = Naught.build
    @null = @null_class.new
  end

  def test_responds_to_arbitrary_messages_and_returns_nil
    assert_nil @null.info
  end

  def test_responds_to_arbitrary_unknown_messages_and_returns_nil
    assert_nil @null.foobaz
  end

  def test_responds_to_to_s_and_returns_nil
    assert_nil @null.to_s
  end

  def test_accepts_any_arguments_for_any_messages
    @null.foobaz(1, 2, 3)
  end

  def test_reports_that_it_responds_to_info
    assert_respond_to @null, :info
  end

  def test_reports_that_it_responds_to_foobaz
    assert_respond_to @null, :foobaz
  end

  def test_reports_that_it_responds_to_to_s
    assert_respond_to @null, :to_s
  end

  def test_can_be_inspected
    assert_equal "<null>", @null.inspect
  end

  def test_knows_its_own_class
    assert_equal @null_class, @null.class
  end

  def test_aliases_new_to_get
    assert_same @null_class, @null_class.get.class
  end
end
