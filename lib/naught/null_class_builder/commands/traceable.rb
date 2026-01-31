require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Records the source location where a null object was created
      #
      # @api private
      class Traceable < Naught::NullClassBuilder::Command
        # Install the traceable initializer
        #
        # @return [void]
        # @api private
        def call
          builder.defer_prepend_module do
            attr_reader :__file__, :__line__

            define_method(:initialize) do |options = {}|
              backtrace = options.fetch(:caller) { Kernel.caller(3) }
              @__file__, line = backtrace[0].split(":")
              @__line__ = line.to_i
              super(options)
            end
          end
        end
      end
    end
  end
end
