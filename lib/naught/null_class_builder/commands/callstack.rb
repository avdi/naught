require "naught/null_class_builder/command"
require "naught/call_location"

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
      #   NullObject = Naught.build { |b| b.callstack }
      #   null = NullObject.new
      #   null.foo.bar
      #   null.baz(1, 2)
      #   null.__call_trace__  #=> [[<foo>, <bar>], [<baz(1, 2)>]]
      #
      # @api private
      class Callstack < Naught::NullClassBuilder::Command
        # Install the callstack tracking mechanism
        #
        # @return [void]
        # @api private
        def call
          # steep:ignore:start
          builder.defer_prepend_module do
            # Each null object tracks its own call traces
            # @__call_trace__ is an array of traces
            # Each trace is an array of CallLocation objects
            attr_reader :__call_trace__

            define_method(:initialize) do |*args, **kwargs|
              super(*args, **kwargs)
              @__call_trace__ = []
            end
          end
          # steep:ignore:end

          # steep:ignore:start
          builder.defer_prepend_module do
            define_method(:respond_to?) do |method_name, include_private = false|
              # These are real methods we define
              return true if method_name == :__call_trace__

              super(method_name, include_private)
            end

            define_method(:method_missing) do |method_name, *args, &block|
              # Parse the caller to get location info
              caller_info = Kernel.caller(1, 1).first
              path, lineno, method_part = caller_info.split(":", 3)
              lineno = lineno.to_i

              # Extract the calling method name from the caller info
              base_label = nil
              if method_part
                match = method_part.match(/['`]([^'`]+)['`]/)
                if match
                  # Extract just the method name, not the full signature
                  sig = match[1]
                  # Handle formats like "block in method" or "Class#method"
                  base_label = sig.split(/[#.]/).last.split(" in ").last
                end
              end

              location = Naught::CallLocation.new(
                label: method_name,
                args: args,
                path: path,
                lineno: lineno,
                base_label: base_label
              )

              # Lazily initialize call trace in case other prepended modules
              # didn't call super in their initialize (e.g., traceable)
              @__call_trace__ ||= []

              # Start a new trace and add this location
              @__call_trace__ << [location]

              # Return a chain proxy that will add to the current trace
              self.class::ChainProxy.new(self, @__call_trace__.last)
            end
          end
          # steep:ignore:end

          # Define the ChainProxy class for tracking chained calls
          # steep:ignore:start
          defer(class: true) do |null_class|
            # Create the ChainProxy as a constant on the null class
            chain_proxy_class = Class.new(Naught::BasicObject) do
              def initialize(root, current_trace)
                @root = root
                @current_trace = current_trace
              end

              def method_missing(method_name, *args, &block)
                # Parse the caller to get location info
                caller_info = ::Kernel.caller(1, 1).first
                path, lineno, method_part = caller_info.split(":", 3)
                lineno = lineno.to_i

                # Extract the calling method name
                base_label = nil
                if method_part
                  match = method_part.match(/['`]([^'`]+)['`]/)
                  if match
                    sig = match[1]
                    base_label = sig.split(/[#.]/).last.split(" in ").last
                  end
                end

                location = ::Naught::CallLocation.new(
                  label: method_name,
                  args: args,
                  path: path,
                  lineno: lineno,
                  base_label: base_label
                )

                @current_trace << location

                # Return self to allow further chaining
                self
              end

              def respond_to?(method_name, include_private = false)
                true
              end

              # :nocov:
              def respond_to_missing?(method_name, include_private = false)
                true
              end
              # :nocov:

              def inspect
                "<null:chain>"
              end

              def class
                @root.class
              end
            end

            null_class.const_set(:ChainProxy, chain_proxy_class)
          end
          # steep:ignore:end
        end
      end
    end
  end
end
