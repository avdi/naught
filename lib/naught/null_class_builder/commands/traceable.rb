require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Records the source location where a null object was created
      #
      # @api private
      class Traceable < Command
        # Install the traceable initializer
        # @return [void]
        # @api private
        def call
          defer_prepend_module do
            attr_reader :__file__, :__line__

            define_method(:initialize) do |options = {}|
              backtrace = options.fetch(:caller) { Kernel.caller(3) }
              caller_data = Naught::CallerInfo.parse(backtrace[0])
              @__file__ = caller_data[:path]
              @__line__ = caller_data[:lineno]
              super(options)
            end
          end
        end
      end
    end
  end
end
