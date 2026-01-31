module Naught
  class NullClassBuilder
    # Base class for builder command implementations
    #
    # @api private
    class Command
      # Builder instance for this command
      # @return [NullClassBuilder]
      # @api private
      attr_reader :builder

      # Create a command bound to a builder
      #
      # @param builder [NullClassBuilder]
      # @return [void]
      # @api private
      def initialize(builder)
        @builder = builder
      end

      # Execute the command
      #
      # @raise [NotImplementedError] when not overridden
      # @return [void]
      # @api private
      def call
        raise NotImplementedError, "Method #call should be overriden in child classes"
      end

      # Delegate a deferred operation to the builder
      #
      # @param options [Hash] operation options
      # @yieldparam subject [Module, Class]
      # @yieldreturn [void]
      # @return [void]
      # @api private
      def defer(options = {}, &)
        @builder.defer(options, &)
      end
    end
  end
end
