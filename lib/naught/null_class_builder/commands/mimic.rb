require "naught/basic_object"
require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Build a null class that mimics an existing class or instance
      #
      # @api private
      class Mimic < Command
        # Methods that should never be mimicked as they interfere with
        # other Naught features like predicates_return
        # @see https://github.com/avdi/naught/issues/55
        METHODS_TO_SKIP = (%i[method_missing respond_to? respond_to_missing?] + Object.instance_methods).freeze
        private_constant :METHODS_TO_SKIP

        # Singleton class placeholder used when no instance is provided
        NULL_SINGLETON_CLASS = Object.new.singleton_class.freeze
        private_constant :NULL_SINGLETON_CLASS

        # The class being mimicked by the null object
        # @return [Class] class being mimicked
        attr_reader :class_to_mimic

        # Whether to include superclass methods when mimicking
        # @return [Boolean] whether to include superclass methods
        attr_reader :include_super

        # The singleton class being mimicked (for instance-based mimicking)
        # @return [Class] singleton class being mimicked
        attr_reader :singleton_class

        # The example instance for dynamic method discovery
        # @return [Object, nil] example instance or nil
        attr_reader :example_instance

        # Whether to include dynamically-defined methods
        # @return [Boolean] whether to include dynamic methods
        attr_reader :include_dynamic

        # Create a mimic command for a class or instance
        #
        # @param builder [NullClassBuilder]
        # @param class_to_mimic_or_options [Class, Hash]
        # @param options [Hash]
        # @api private
        def initialize(builder, class_to_mimic_or_options, options = {})
          super(builder)
          parse_arguments(class_to_mimic_or_options, options)
          configure_builder
        end

        # Install stubbed methods from the target class or instance
        #
        # @return [void]
        # @api private
        def call
          defer { |subject| methods_to_stub.each { |name| builder.stub_method(subject, name) } }
        end

        private

        # Parse the arguments to determine what to mimic
        #
        # @param class_to_mimic_or_options [Class, Hash] class or options hash
        # @param options [Hash] additional options
        # @return [void]
        def parse_arguments(class_to_mimic_or_options, options)
          if class_to_mimic_or_options.is_a?(Hash)
            options = class_to_mimic_or_options.merge(options)
            @example_instance = options.fetch(:example)
            @singleton_class = @example_instance.singleton_class
            @class_to_mimic = @example_instance.class
          else
            @example_instance = nil
            @singleton_class = NULL_SINGLETON_CLASS
            @class_to_mimic = class_to_mimic_or_options
          end
          @include_super = options.fetch(:include_super, true)
          @include_dynamic = options.fetch(:include_dynamic, !@example_instance.nil?)
        end

        # Configure the builder with the mimicked class's properties
        #
        # @return [void]
        def configure_builder
          builder.base_class = root_class_of(class_to_mimic)
          klass = class_to_mimic
          builder.inspect_proc = -> { "<null:#{klass}>" }
          builder.interface_defined = true
        end

        # Determine the root class to inherit from
        #
        # @param klass [Class] the class to analyze
        # @return [Class] Object or Naught::BasicObject
        def root_class_of(klass) = klass.ancestors.include?(Object) ? Object : Naught::BasicObject

        # Compute the list of methods to stub on the null object
        #
        # @return [Array<Symbol>] methods to stub
        def methods_to_stub
          all_methods = class_to_mimic.instance_methods(include_super) | singleton_class.instance_methods(false)
          all_methods |= dynamic_methods if include_dynamic
          all_methods - METHODS_TO_SKIP
        end

        # Discover dynamically-defined methods from the example instance
        #
        # This handles classes like Stripe that use method_missing and
        # respond_to_missing? to define methods based on instance data.
        #
        # @return [Array<Symbol>] dynamic method names
        def dynamic_methods
          return [] unless example_instance

          candidates = discover_method_candidates
          candidates.select { |name| example_instance.respond_to?(name) }
        end

        # Discover candidate method names from the example instance
        #
        # Tries multiple approaches to find method names:
        # 1. If the instance responds to :keys (like Stripe objects), use those
        # 2. If the instance responds to :attributes, use those
        # 3. If the instance responds to :to_h or :to_hash, use the hash keys
        #
        # @return [Array<Symbol>] candidate method names
        def discover_method_candidates
          candidates = [] #: Array[Symbol]

          # Stripe-style objects expose keys
          candidates |= example_instance.keys.map(&:to_sym) if example_instance.respond_to?(:keys)

          # ActiveRecord-style objects expose attribute_names
          if example_instance.respond_to?(:attribute_names)
            candidates |= example_instance.attribute_names.map(&:to_sym)
          end

          # OpenStruct-style objects can be converted to hash
          if example_instance.respond_to?(:to_h) && !example_instance.is_a?(Object.const_get(:Hash))
            begin
              hash = example_instance.to_h
              candidates |= hash.keys.map(&:to_sym) if hash.is_a?(Hash)
            rescue
              # Ignore errors from to_h
            end
          end

          candidates
        end
      end
    end
  end
end
