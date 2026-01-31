require "test_helper"

class CallerInfoParseTest < NaughtTestCase
  def test_parses_simple_caller_string
    result = Naught::CallerInfo.parse("/path/to/file.rb:42:in `method_name'")

    assert_equal "/path/to/file.rb", result[:path]
    assert_equal 42, result[:lineno]
    assert_equal "method_name", result[:base_label]
  end

  def test_parses_caller_without_method_info
    result = Naught::CallerInfo.parse("/path/to/file.rb:10")

    assert_equal "/path/to/file.rb", result[:path]
    assert_equal 10, result[:lineno]
    assert_nil result[:base_label]
  end

  def test_parses_block_in_method
    result = Naught::CallerInfo.parse("/path/to/file.rb:5:in `block in my_method'")

    assert_equal "my_method", result[:base_label]
  end

  def test_parses_class_method
    result = Naught::CallerInfo.parse("/path/to/file.rb:5:in `MyClass#instance_method'")

    assert_equal "instance_method", result[:base_label]
  end

  def test_parses_nested_block
    result = Naught::CallerInfo.parse("/path/to/file.rb:5:in `block (2 levels) in my_method'")

    assert_equal "my_method", result[:base_label]
  end
end

class CallerInfoExtractBaseLabelTest < NaughtTestCase
  def test_returns_nil_for_nil_input
    assert_nil Naught::CallerInfo.extract_base_label(nil)
  end

  def test_returns_nil_when_no_quotes_present
    assert_nil Naught::CallerInfo.extract_base_label("no quotes here")
  end

  def test_extracts_simple_method_name
    assert_equal "foo", Naught::CallerInfo.extract_base_label("in `foo'")
  end
end

class CallerInfoExtractSignatureTest < NaughtTestCase
  def test_returns_nil_for_nil_input
    assert_nil Naught::CallerInfo.extract_signature(nil)
  end

  def test_returns_nil_when_no_quotes_present
    assert_nil Naught::CallerInfo.extract_signature("no quotes here")
  end

  def test_extracts_quoted_signature
    assert_equal "my_method", Naught::CallerInfo.extract_signature("in `my_method'")
  end

  def test_extracts_block_signature
    assert_equal "block in my_method", Naught::CallerInfo.extract_signature("in `block in my_method'")
  end
end

class CallerInfoSplitSignatureTest < NaughtTestCase
  def test_splits_block_signature
    block_info, method_name = Naught::CallerInfo.split_signature("block in my_method")

    assert_equal "block", block_info
    assert_equal "my_method", method_name
  end

  def test_returns_nil_block_info_for_simple_method
    block_info, method_name = Naught::CallerInfo.split_signature("my_method")

    assert_nil block_info
    assert_equal "my_method", method_name
  end
end

class CallerInfoFormatCallerForPebbleTest < NaughtTestCase
  def test_formats_simple_method_call
    stack = ["/path/to/file.rb:10:in `my_method'"]

    assert_equal "my_method", Naught::CallerInfo.format_caller_for_pebble(stack)
  end

  def test_formats_block_call
    stack = ["/path/to/file.rb:10:in `block in my_method'"]

    assert_equal "block my_method", Naught::CallerInfo.format_caller_for_pebble(stack)
  end

  def test_returns_raw_caller_when_unrecognized_format
    stack = ["unusual format without method info"]

    assert_equal "unusual format without method info", Naught::CallerInfo.format_caller_for_pebble(stack)
  end
end

class CallerInfoCountBlockLevelsTest < NaughtTestCase
  def test_counts_single_block_level
    stack = [
      "/path/to/file.rb:10:in `block in my_method'",
      "/path/to/file.rb:5:in `my_method'"
    ]

    assert_equal 1, Naught::CallerInfo.count_block_levels(stack, "my_method")
  end

  def test_counts_multiple_block_levels
    stack = [
      "/path/to/file.rb:10:in `block in my_method'",
      "/path/to/file.rb:8:in `block in each'",
      "/path/to/file.rb:7:in `block in my_method'",
      "/path/to/file.rb:5:in `my_method'"
    ]

    assert_equal 2, Naught::CallerInfo.count_block_levels(stack, "my_method")
  end

  def test_stops_at_non_matching_entry
    stack = [
      "/path/to/file.rb:10:in `block in my_method'",
      "/path/to/file.rb:8:in `other_method'",
      "/path/to/file.rb:5:in `my_method'"
    ]

    assert_equal 1, Naught::CallerInfo.count_block_levels(stack, "my_method")
  end

  def test_stops_when_no_signature_found
    stack = [
      "/path/to/file.rb:10:in `block in my_method'",
      "unusual format without method info",
      "/path/to/file.rb:5:in `my_method'"
    ]

    assert_equal 1, Naught::CallerInfo.count_block_levels(stack, "my_method")
  end
end
