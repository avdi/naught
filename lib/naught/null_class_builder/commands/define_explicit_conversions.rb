require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Adds explicit conversion methods delegating to nil
      #
      # These methods return the same values that nil returns:
      # - to_a => []
      # - to_c => (0+0i)
      # - to_f => 0.0
      # - to_h => {}
      # - to_i => 0
      # - to_r => (0/1)
      # - to_s => ""
      #
      # @api private
      class DefineExplicitConversions < Command
        METHODS = %i[to_a to_c to_f to_h to_i to_r to_s].freeze
        private_constant :METHODS

        # Install explicit conversion methods
        # @return [void]
        # @api private
        def call
          defer { |subject| METHODS.each { |name| subject.define_method(name) { nil.public_send(name) } } }
        end
      end
    end
  end
end
