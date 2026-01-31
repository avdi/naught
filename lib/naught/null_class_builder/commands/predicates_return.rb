require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Overrides predicate methods to return a fixed value
      #
      # @api private
      class PredicatesReturn < Naught::NullClassBuilder::Command
        # Create a predicates_return command with the given value
        # @param builder [NullClassBuilder]
        # @param return_value [Object] value to return for predicate methods
        # @return [void]
        # @api private
        def initialize(builder, return_value)
          super(builder)
          @predicate_return_value = return_value
        end

        # Apply predicate overrides
        #
        # @return [void]
        # @api private
        def call
          return_value = @predicate_return_value

          # Override method_missing and respond_to? via prepend to avoid redefinition warnings
          builder.defer_prepend_module do
            define_method(:method_missing) do |method_name, *args, &block|
              if method_name.to_s.end_with?("?")
                return_value
              else
                super(method_name, *args, &block)
              end
            end

            define_method(:respond_to?) do |method_name, include_private = false|
              method_name.to_s.end_with?("?") || super(method_name, include_private)
            end
          end

          # Collect predicate methods and create a prepend module for them
          defer do |subject|
            predicate_methods = subject.instance_methods.select do |method_name|
              method_name.to_s.end_with?("?") && method_name != :respond_to?
            end

            next if predicate_methods.empty?

            predicate_mod = Module.new do
              predicate_methods.each do |method_name|
                define_method(method_name) { |*| return_value }
              end
            end
            subject.prepend(predicate_mod)
          end
        end
      end
    end
  end
end
