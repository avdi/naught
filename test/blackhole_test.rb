require "test_helper"

class BlackholeTest < Minitest::Test
  def setup
    @null_class = Naught.build(&:black_hole)
    @null = @null_class.new
  end

  def test_returns_self_from_info_method_call
    assert_same @null, @null.info
  end

  def test_returns_self_from_foobaz_method_call
    assert_same @null, @null.foobaz
  end

  def test_returns_self_from_shift_method_call
    assert_same @null, @null << "bar"
  end
end

# Test for GitHub issue #72: black_hole and Marshal.dump don't work together
# https://github.com/avdi/naught/issues/72
# Marshal requires classes to be assigned to constants, so we define these outside the test class
MarshalableBlackHole = Naught.build(&:black_hole)

class BlackholeMarshalTest < Minitest::Test
  def setup
    @null = MarshalableBlackHole.new
  end

  def test_can_be_marshaled_and_unmarshaled
    dumped = Marshal.dump(@null)
    loaded = Marshal.load(dumped)

    assert_kind_of MarshalableBlackHole, loaded
  end

  def test_marshaled_object_still_behaves_as_black_hole
    loaded = Marshal.load(Marshal.dump(@null))

    assert_same loaded, loaded.foo
    assert_same loaded, loaded.bar.baz
  end
end
