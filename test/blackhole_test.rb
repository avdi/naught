require "test_helper"

class BlackholeTest < NaughtTestCase
  def setup
    @null_class, @null = build_null(&:black_hole)
  end

  def test_returns_self_from_any_method
    assert_returns_self @null, :info
    assert_returns_self @null, :foobaz
    assert_same @null, @null << "bar"
  end
end

# Test for GitHub issue #72: black_hole and Marshal.dump don't work together
# https://github.com/avdi/naught/issues/72
# Note: Marshal requires a named constant, so we define one within the test class
class BlackholeMarshalTest < NaughtTestCase
  MarshalableBlackHole = Naught.build(&:black_hole)

  def setup
    @null = MarshalableBlackHole.new
  end

  def test_can_be_marshaled_and_unmarshaled
    loaded = Marshal.load(Marshal.dump(@null))

    assert_kind_of MarshalableBlackHole, loaded
  end

  def test_marshaled_object_retains_black_hole_behavior
    loaded = Marshal.load(Marshal.dump(@null))

    assert_same loaded, loaded.foo
    assert_same loaded, loaded.bar.baz
  end
end
