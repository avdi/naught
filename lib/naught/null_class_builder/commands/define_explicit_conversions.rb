require "forwardable"
require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Adds explicit conversion methods delegating to nil
      #
      # @api private
      class DefineExplicitConversions < ::Naught::NullClassBuilder::Command
        # Install explicit conversion methods
        #
        # @return [void]
        # @api private
        def call
          defer do |subject|
            subject.module_eval do
              extend Forwardable

              def_delegators :nil, :to_a, :to_c, :to_f, :to_h, :to_i, :to_r, :to_s
            end
          end
        end
      end
    end
  end
end
