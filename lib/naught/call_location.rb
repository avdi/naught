module Naught
  # Represents a single method call in a null object's call trace
  #
  # This class provides an interface similar to Thread::Backtrace::Location,
  # capturing information about where a method was called on a null object.
  #
  # @api public
  class CallLocation
    # Create a CallLocation from a caller string
    #
    # @param method_name [Symbol, String] the method that was called
    # @param args [Array<Object>] arguments passed to the method
    # @param caller_string [String, nil] a single entry from Kernel.caller
    # @return [CallLocation]
    # @api private
    def self.from_caller(method_name, args, caller_string)
      data = CallerInfo.parse(caller_string || "")
      new(
        label: method_name,
        args: args,
        path: data[:path] || "",
        lineno: data[:lineno],
        base_label: data[:base_label]
      )
    end

    # The name of the method that was called
    #
    # @return [String] the name of the method that was called
    # @example
    #   location.label #=> "foo"
    attr_reader :label

    # Arguments passed to the method call
    #
    # @return [Array<Object>] arguments passed to the method call
    # @example
    #   location.args #=> [1, 2, 3]
    attr_reader :args

    # The absolute path to the file where the call originated
    #
    # @return [String] the absolute path to the file where the call originated
    # @example
    #   location.path #=> "/path/to/file.rb"
    attr_reader :path

    # @!method absolute_path
    #   Returns the absolute path (alias for {#path})
    #   @return [String] the absolute path to the file
    #   @example
    #     location.absolute_path #=> "/path/to/file.rb"
    alias_method :absolute_path, :path

    # The line number where the call originated
    #
    # @return [Integer] the line number where the call originated
    # @example
    #   location.lineno #=> 42
    attr_reader :lineno

    # The name of the method that made the call
    #
    # @return [String, nil] the name of the method that made the call
    # @example
    #   location.base_label #=> "some_method"
    attr_reader :base_label

    # Initialize a new CallLocation
    #
    # @param label [Symbol, String] the method that was called
    # @param args [Array<Object>] arguments passed to the method
    # @param path [String] path to the file where the call originated
    # @param lineno [Integer] line number where the call originated
    # @param base_label [String, nil] name of the method that made the call
    # @api private
    def initialize(label:, args:, path:, lineno:, base_label: nil)
      @label = label.to_s
      @args = args.dup.freeze
      @path = path
      @lineno = lineno
      @base_label = base_label
    end

    # Returns a human-readable string representation of the call
    #
    # @return [String] string representation
    # @example
    #   location.to_s #=> "/path/to/file.rb:42:in `method' -> foo(1, 2)"
    def to_s
      pretty_args = args.map(&:inspect).join(", ")
      location = base_label ? "#{path}:#{lineno}:in `#{base_label}'" : "#{path}:#{lineno}"
      "#{location} -> #{label}(#{pretty_args})"
    end

    # Returns a detailed inspect representation
    #
    # @return [String] inspect representation
    # @example
    #   location.inspect #=> "#<Naught::CallLocation /path/to/file.rb:42 -> foo(1)>"
    def inspect = "#<#{self.class} #{self}>"

    # Compare this CallLocation with another for equality
    #
    # @param other [CallLocation] the object to compare with
    # @return [Boolean] true if all attributes match
    # @example
    #   location1 == location2 #=> true
    def ==(other)
      other.is_a?(CallLocation) &&
        label == other.label &&
        args == other.args &&
        path == other.path &&
        lineno == other.lineno &&
        base_label == other.base_label
    end
    # @!method eql?
    #   Compare for equality (alias for {#==})
    #   @return [Boolean] true if all attributes match
    #   @example
    #     location1.eql?(location2) #=> true
    alias_method :eql?, :==

    # Compute a hash value for this CallLocation
    #
    # @return [Integer] hash value based on all attributes
    # @example
    #   location.hash #=> 123456789
    def hash = [label, args, path, lineno, base_label].hash
  end
end
