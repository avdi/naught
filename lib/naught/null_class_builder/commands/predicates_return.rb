require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Overrides predicate methods to return a fixed value
      #
      # @api private
      class PredicatesReturn < Command
        # Create a predicates_return command with the given value
        #
        # @param builder [NullClassBuilder]
        # @param return_value [Object] value to return for predicate methods
        # @api private
        def initialize(builder, return_value)
          super(builder)
          @return_value = return_value
        end

        # Apply predicate overrides
        # @return [void]
        # @api private
        def call
          install_method_missing_override
          install_predicate_method_overrides
        end

        private

        # Install method_missing override for predicate methods
        # @return [void]
        # @api private
        def install_method_missing_override
          return_value = @return_value
          defer_prepend_module do
            define_method(:method_missing) do |method_name, *args, &block|
              method_name.to_s.end_with?("?") ? return_value : super(method_name, *args, &block)
            end

            define_method(:respond_to?) do |method_name, include_private = false|
              method_name.to_s.end_with?("?") || super(method_name, include_private)
            end
          end
        end

        # Override existing predicate methods to return the configured value
        # @return [void]
        # @api private
        def install_predicate_method_overrides
          return_value = @return_value
          defer do |subject|
            predicate_methods = subject.instance_methods.select do |name|
              name.to_s.end_with?("?") && name != :respond_to?
            end
            next if predicate_methods.empty?

            predicate_mod = Module.new do
              predicate_methods.each { |name| define_method(name) { |*| return_value } }
            end
            subject.prepend(predicate_mod)
          end
        end
      end
    end
  end
end
