module Naught
  # Represents a single method call in a null object's call trace
  #
  # This class provides an interface similar to Thread::Backtrace::Location,
  # capturing information about where a method was called on a null object.
  #
  # @api public
  class CallLocation
    # The name of the method that was called
    #
    # @example Get the method name
    #   location.label  #=> "foo"
    #
    # @return [String]
    # @api public
    attr_reader :label

    # Arguments passed to the method call
    #
    # @example Get the arguments
    #   location.args  #=> [1, "hello"]
    #
    # @return [Array<Object>]
    # @api public
    attr_reader :args

    # The absolute path to the file where the call originated
    #
    # @example Get the file path
    #   location.path  #=> "/path/to/file.rb"
    #
    # @return [String]
    # @api public
    attr_reader :path

    # @return [String] alias for {#path}
    alias_method :absolute_path, :path

    # The line number where the call originated
    #
    # @example Get the line number
    #   location.lineno  #=> 42
    #
    # @return [Integer]
    # @api public
    attr_reader :lineno

    # The name of the method that made the call
    #
    # @example Get the caller method name
    #   location.base_label  #=> "some_method"
    #
    # @return [String, nil]
    # @api public
    attr_reader :base_label

    # Create a new CallLocation
    #
    # @param label [Symbol, String] the method name that was called
    # @param args [Array<Object>] arguments passed to the method
    # @param path [String] file path where the call originated
    # @param lineno [Integer] line number where the call originated
    # @param base_label [String, nil] the calling method name
    # @return [void]
    # @api private
    def initialize(label:, args:, path:, lineno:, base_label: nil)
      @label = label.to_s
      @args = args.dup.freeze
      @path = path
      @lineno = lineno
      @base_label = base_label
    end

    # String representation of this call location
    #
    # @example Get string representation
    #   location.to_s  #=> "/path/to/file.rb:42:in `some_method' -> foo(1, 'hello')"
    #
    # @return [String]
    # @api public
    def to_s
      pretty_args = args.map(&:inspect).join(", ")
      caller_part = base_label ? "in `#{base_label}'" : ""
      location_part = "#{path}:#{lineno}"
      location_part += ":#{caller_part}" unless caller_part.empty?
      "#{location_part} -> #{label}(#{pretty_args})"
    end

    # Inspect representation of this call location
    #
    # @example Get inspect representation
    #   location.inspect  #=> "#<Naught::CallLocation /path:42 -> foo()>"
    #
    # @return [String]
    # @api public
    def inspect
      "#<#{self.class} #{self}>"
    end

    # Compare two CallLocation objects for equality
    #
    # @example Compare two locations
    #   location1 == location2  #=> true
    #
    # @param other [CallLocation]
    # @return [Boolean]
    # @api public
    def ==(other)
      return false unless other.is_a?(CallLocation)

      label == other.label &&
        args == other.args &&
        path == other.path &&
        lineno == other.lineno &&
        base_label == other.base_label
    end

    # @return [Boolean] alias for {#==}
    alias_method :eql?, :==

    # Hash code for this call location
    #
    # @example Get hash code
    #   location.hash  #=> 12345
    #
    # @return [Integer]
    # @api public
    def hash
      [label, args, path, lineno, base_label].hash
    end
  end
end
