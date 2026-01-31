module Naught
  class NullClassBuilder
    module Commands
      # Build a null class that impersonates a given class
      #
      # Unlike Mimic, Impersonate makes the null class inherit from the target,
      # so `is_a?` checks will pass.
      #
      # @api private
      class Impersonate < Mimic
        # Create an impersonate command for a class
        #
        # @param builder [NullClassBuilder]
        # @param class_to_impersonate [Class]
        # @param options [Hash]
        # @api private
        def initialize(builder, class_to_impersonate, options = {})
          super
          builder.base_class = class_to_impersonate
        end
      end
    end
  end
end
