require "naught/basic_object"
require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Build a null class that mimics an existing class or instance
      #
      # @api private
      class Mimic < Naught::NullClassBuilder::Command
        # Singleton class placeholder used when no instance is provided
        NULL_SINGLETON_CLASS = (class << Object.new; self; end)

        # Class being mimicked
        # @return [Class]
        # @api private
        attr_reader :class_to_mimic

        # Whether to include superclass methods
        # @return [Boolean]
        # @api private
        attr_reader :include_super

        # Singleton class being mimicked
        # @return [Class]
        # @api private
        attr_reader :singleton_class

        # Create a mimic command for a class or instance
        # @param builder [NullClassBuilder]
        # @param class_to_mimic_or_options [Class, Hash]
        # @param options [Hash]
        # @return [void]
        # @api private
        def initialize(builder, class_to_mimic_or_options, options = {})
          super(builder)

          if class_to_mimic_or_options.is_a?(Hash)
            options = class_to_mimic_or_options.merge(options)
            instance = options.fetch(:example)
            @singleton_class = (class << instance; self; end)
            @class_to_mimic = instance.class
          else
            @singleton_class = NULL_SINGLETON_CLASS
            @class_to_mimic = class_to_mimic_or_options
          end
          @include_super = options.fetch(:include_super) { true }

          builder.base_class = root_class_of(@class_to_mimic)
          class_to_mimic = @class_to_mimic
          builder.inspect_proc = -> { "<null:#{class_to_mimic}>" }
          builder.interface_defined = true
        end

        # Install stubbed methods from the target class or instance
        #
        # @return [void]
        # @api private
        def call
          defer do |subject|
            methods_to_stub.each do |method_name|
              builder.stub_method(subject, method_name)
            end
          end
        end

        private

        # Determine the appropriate base class
        # @param klass [Class]
        # @return [Class]
        # @api private
        def root_class_of(klass)
          klass.ancestors.include?(Object) ? Object : Naught::BasicObject
        end

        # Methods that should never be mimicked as they interfere with
        # other Naught features like predicates_return
        # @see https://github.com/avdi/naught/issues/55
        METHODS_TO_SKIP = %i[method_missing respond_to? respond_to_missing?].freeze

        # Compute methods to stub from the mimicked class
        # @return [Array<Symbol>]
        # @api private
        def methods_to_stub
          methods_to_mimic =
            class_to_mimic.instance_methods(include_super) |
            singleton_class.instance_methods(false)
          methods_to_mimic - Object.instance_methods - METHODS_TO_SKIP
        end
      end
    end
  end
end
