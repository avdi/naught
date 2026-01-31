module Naught
  # Utility for parsing Ruby caller/backtrace information
  #
  # Extracts structured information from caller strings like:
  #   "/path/to/file.rb:42:in `method_name'"
  #   "/path/to/file.rb:42:in `block in method_name'"
  #   "/path/to/file.rb:42:in `block (2 levels) in method_name'"
  #
  # @api private
  module CallerInfo
    # Pattern matching quoted method signature in caller strings
    # Matches both backticks and single quotes for cross-Ruby compatibility
    SIGNATURE_PATTERN = /['`](?<signature>[^'`]+)['`]$/
    private_constant :SIGNATURE_PATTERN

    module_function

    # Parse a caller string into structured components
    #
    # @param caller_string [String] a single entry from Kernel.caller
    # @return [Hash] parsed components with keys :path, :lineno, :base_label
    def parse(caller_string)
      path, lineno, method_part = caller_string.to_s.split(":", 3)
      {
        path: path,
        lineno: lineno.to_i,
        base_label: extract_base_label(method_part)
      }
    end

    # Format caller information for display in pebble output
    #
    # Handles nested block detection by examining the call stack.
    #
    # @param stack [Array<String>] the call stack from Kernel.caller
    # @return [String] formatted caller description
    def format_caller_for_pebble(stack)
      caller_line = stack.first
      signature = extract_signature(caller_line.split(":", 3)[2])
      return caller_line unless signature

      block_info, method_name = parse_signature(signature)
      block_info = adjusted_block_info(block_info, stack, method_name)

      block_info ? "#{block_info} #{method_name}" : method_name
    end

    # Extract the base method name from the method part of a caller string
    #
    # @param method_part [String, nil] the third component after splitting on ":"
    # @return [String, nil] the extracted method name
    def extract_base_label(method_part)
      signature = extract_signature(method_part)
      return nil unless signature

      _block_info, method_name = parse_signature(signature)
      method_name
    end

    # Extract the full method signature including block info
    #
    # @param method_part [String, nil] the third component after splitting on ":"
    # @return [String, nil] the full signature
    def extract_signature(method_part)
      method_part&.match(SIGNATURE_PATTERN)&.[](:signature)
    end

    # Split a signature into block info and base method name
    #
    # @param signature [String] the method signature
    # @return [Array(String, String), Array(nil, String)] [block_info, method_name]
    def split_signature(signature)
      signature.include?(" in ") ? signature.split(" in ", 2) : [nil, signature]
    end

    # Count nested block levels in the call stack
    #
    # @param stack [Array<String>] the call stack
    # @param target_method [String] the method name to look for
    # @return [Integer] the number of nested block levels
    def count_block_levels(stack, target_method)
      stack.reduce(0) do |levels, entry|
        signature = extract_signature(entry.split(":", 3)[2])
        break levels unless signature

        block_info, method_name = parse_signature(signature)

        if method_name == target_method
          block_info&.start_with?("block") ? levels + 1 : (break levels)
        else
          levels
        end
      end
    end

    # Parse a signature into block info and clean method name
    #
    # @param signature [String] the method signature
    # @return [Array(String, String), Array(nil, String)] [block_info, method_name]
    def parse_signature(signature)
      block_info, method_part = split_signature(signature)
      method_name = method_part.split(/[#.]/).last
      [block_info, method_name]
    end

    # Adjust block info to show nested levels if applicable
    #
    # @param block_info [String, nil] current block info
    # @param stack [Array<String>] the call stack
    # @param method_name [String] the method name to look for
    # @return [String, nil] adjusted block info
    def adjusted_block_info(block_info, stack, method_name)
      return block_info unless simple_block?(block_info)

      levels = count_block_levels(stack, method_name)
      (levels > 1) ? "block (#{levels} levels)" : block_info
    end

    # Check if block_info is a simple "block" without level info
    #
    # @param block_info [String, nil]
    # @return [Boolean]
    def simple_block?(block_info)
      block_info&.start_with?("block") && !block_info.include?("levels")
    end
    private :parse_signature, :adjusted_block_info, :simple_block?
  end
end
