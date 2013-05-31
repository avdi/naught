require 'naught/null_class_builder/command'

module Naught
  class NullClassBuilder
    module Commands
      class PredicatesReturn < Naught::NullClassBuilder::Command
        def initialize(builder, return_value)
          super(builder)
          @predicate_return_value = return_value
        end

        def call
          defer do |subject|
            define_method_missing(subject)
            define_predicate_methods(subject)
          end
        end

        private

        def define_method_missing(subject)
          return_value = @predicate_return_value
          subject.module_eval do
            if subject.method_defined?(:method_missing)
              original_method_missing = instance_method(:method_missing)
              define_method(:method_missing) do
                |method_name, *args, &block|
                if method_name.to_s.end_with?('?')
                  return_value
                else
                  original_method_missing.bind(self).call(method_name, *args, &block)
                end
              end
            end
          end
        end

        def define_predicate_methods(subject)
          return_value = @predicate_return_value
          subject.module_eval do
            instance_methods.each do |method_name|
              if method_name.to_s.end_with?('?')
                define_method(method_name) do |*|
                  return_value
                end
              end
            end
          end
        end
      end
    end
  end
end
