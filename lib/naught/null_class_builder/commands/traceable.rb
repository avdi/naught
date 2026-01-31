require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      class Traceable < Naught::NullClassBuilder::Command
        def call
          builder.defer_prepend_module do
            attr_reader :__file__, :__line__

            define_method(:initialize) do |options = {}|
              backtrace = options.fetch(:caller) { Kernel.caller(3) }
              @__file__, line = backtrace[0].split(":")
              @__line__ = line.to_i
            end
          end
        end
      end
    end
  end
end
