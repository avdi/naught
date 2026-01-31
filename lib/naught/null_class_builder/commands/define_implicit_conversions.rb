require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Adds implicit conversion methods to the null class
      #
      # @api private
      class DefineImplicitConversions < Command
        EMPTY_ARRAY = [] #: Array[untyped]
        EMPTY_HASH = {} #: Hash[untyped, untyped]
        RETURN_VALUES = {
          to_ary: EMPTY_ARRAY.freeze,
          to_hash: EMPTY_HASH.freeze,
          to_int: 0,
          to_str: "".freeze
        }.freeze
        private_constant :EMPTY_ARRAY, :EMPTY_HASH, :RETURN_VALUES

        # Install implicit conversion methods
        # @return [void]
        # @api private
        def call
          defer { |subject| RETURN_VALUES.each { |name, value| subject.define_method(name) { value } } }
        end
      end
    end
  end
end
