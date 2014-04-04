require 'naught/basic_object'
require 'naught/null_class_builder/command'

module Naught
  class NullClassBuilder
    module Commands
      class Mimic < Naught::NullClassBuilder::Command
        attr_reader :class_to_mimic, :include_super, :instance_to_mimic

        def initialize(builder, class_to_mimic, options = {})
          super(builder)

          @class_to_mimic = class_to_mimic
          @include_super = options.fetch(:include_super) { true }
          @instance_to_mimic = options.fetch(:example) { nil }

          builder.base_class   = root_class_of(class_to_mimic)
          builder.inspect_proc = lambda { "<null:#{class_to_mimic}>" }
          builder.interface_defined = true
        end

        def call
          defer do |subject|
            methods_to_stub.each do |method_name|
              builder.stub_method(subject, method_name)
            end
          end
        end

      private

        def root_class_of(klass)
          klass.ancestors.include?(Object) ? Object : Naught::BasicObject
        end

        def methods_to_stub
          methods_to_mimic = if instance_to_mimic
            instance_to_mimic.public_methods(include_super)
          else
            class_to_mimic.instance_methods(include_super)
          end

          methods_to_mimic - Object.instance_methods
        end
      end
    end
  end
end
