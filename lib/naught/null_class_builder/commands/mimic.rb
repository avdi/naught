require 'naught/null_class_builder/command'

module Naught
  class NullClassBuilder
    module Commands
      class Mimic < Naught::NullClassBuilder::Command
        def initialize(builder, class_to_mimic, options={})
          super(builder)

          @class_to_mimic = class_to_mimic
          @include_super = options.fetch(:include_super) { true }

          builder.base_class   = root_class_of(class_to_mimic)
          builder.inspect_proc = -> { "<null:#{class_to_mimic}>" }
          builder.interface_defined = true
        end

        def call
          defer do |subject|
            methods = @class_to_mimic.instance_methods(@include_super) -
              Object.instance_methods
            methods.each do |method_name|
              @builder.stub_method(subject, method_name)
            end
          end
        end

        private

        def root_class_of(klass)
          if klass.ancestors.include?(Object)
            Object
          else
            BasicObject
          end
        end
      end
    end
  end
end

