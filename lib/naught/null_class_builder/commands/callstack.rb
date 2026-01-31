require "naught/null_class_builder/command"
require "naught/call_location"
require "naught/chain_proxy"

module Naught
  class NullClassBuilder
    module Commands
      # Records method calls made on null objects for debugging
      #
      # When enabled, each null object instance tracks all method calls made to it,
      # including the method name, arguments, and source location. Calls are grouped
      # into "traces" - each time a method is called directly on the original null
      # object (rather than on a chained result), a new trace begins.
      #
      # This uses lightweight proxy objects for chaining so that we can distinguish
      # between `null.foo.bar` (one trace with two calls) and `null.foo; null.bar`
      # (two traces with one call each).
      #
      # @example Basic usage
      #   NullObject = Naught.build do |config|
      #     config.callstack
      #   end
      #
      #   null = NullObject.new
      #   null.foo(1, 2).bar
      #   null.baz
      #
      #   null.__call_trace__
      #   # => [
      #   #      [#<Naught::CallLocation foo(1, 2) at example.rb:8>,
      #   #       #<Naught::CallLocation bar() at example.rb:8>],
      #   #      [#<Naught::CallLocation baz() at example.rb:9>]
      #   #    ]
      #
      # @api private
      class Callstack < Command
        # Install the callstack tracking mechanism
        # @return [void]
        # @api private
        def call
          install_call_trace_accessor
          install_method_missing_tracking
          install_chain_proxy_class
        end

        private

        # Install the __call_trace__ accessor on null objects
        # @return [void]
        # @api private
        def install_call_trace_accessor
          defer_prepend_module do
            attr_reader :__call_trace__

            define_method(:initialize) do |*args, **kwargs|
              super(*args, **kwargs)
              @__call_trace__ = [] #: Array[Array[Naught::CallLocation]]
            end
          end
        end

        # Install method_missing override that records calls
        # @return [void]
        # @api private
        def install_method_missing_tracking
          defer_prepend_module do
            define_method(:respond_to?) do |method_name, include_private = false|
              method_name == :__call_trace__ || super(method_name, include_private)
            end

            define_method(:method_missing) do |method_name, *args, &block|
              location = Naught::CallLocation.from_caller(method_name, args, Kernel.caller(1, 1).first)
              @__call_trace__ ||= [] #: Array[Array[Naught::CallLocation]]
              @__call_trace__ << [location]
              Naught::ChainProxy.new(self, @__call_trace__.last)
            end
          end
        end

        # Install the ChainProxy class constant for backwards compatibility
        # @return [void]
        # @api private
        def install_chain_proxy_class
          defer_class { |null_class| null_class.const_set(:ChainProxy, Naught::ChainProxy) }
        end
      end
    end
  end
end
