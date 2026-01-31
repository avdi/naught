module Naught
  class NullClassBuilder
    module Commands
      # Build a null class that impersonates a given class
      #
      # @api private
      class Impersonate < Naught::NullClassBuilder::Commands::Mimic
        # Create an impersonate command for a class
        # @param builder [NullClassBuilder]
        # @param class_to_impersonate [Class]
        # @param options [Hash]
        # @return [void]
        # @api private
        def initialize(builder, class_to_impersonate, options = {})
          super
          builder.base_class = class_to_impersonate
        end
      end
    end
  end
end
