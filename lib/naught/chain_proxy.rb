require "naught/basic_object"

module Naught
  # Lightweight proxy for tracking chained method calls
  #
  # Used by the callstack feature to group chained method calls
  # (e.g., `null.foo.bar.baz`) into a single trace while keeping
  # separate calls (e.g., `null.foo; null.bar`) in separate traces.
  #
  # @api private
  class ChainProxy < BasicObject
    # Create a new ChainProxy
    #
    # @param root [Object] the original null object being tracked
    # @param current_trace [Array<CallLocation>] the trace to append calls to
    def initialize(root, current_trace)
      @root = root
      @current_trace = current_trace
    end

    # Handle method calls by recording them and returning self for chaining
    #
    # @param method_name [Symbol] the method being called
    # @param args [Array] arguments passed to the method
    # @return [ChainProxy] self for method chaining
    # rubocop:disable Style/MissingRespondToMissing -- BasicObject doesn't use respond_to_missing?
    def method_missing(method_name, *args)
      location = ::Naught::CallLocation.from_caller(
        method_name, args, ::Kernel.caller(1, 1).first
      )
      @current_trace << location
      self
    end
    # rubocop:enable Style/MissingRespondToMissing

    # Check if the proxy responds to a method
    #
    # @return [true] chain proxies respond to any method
    def respond_to?(*, **) = true

    # Return a string representation of the proxy
    #
    # @return [String] a simple representation of the proxy
    def inspect = "<null:chain>"

    # Return the class of the root null object
    #
    # @return [Class] the class of the root null object
    def class = @root.class
  end
end
