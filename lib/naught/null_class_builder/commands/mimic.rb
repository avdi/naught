require 'naught/basic_object'
require 'naught/null_class_builder/command'

module Naught::NullClassBuilder::Commands
  class Mimic < Naught::NullClassBuilder::Command
    attr_reader :class_to_mimic, :include_super

    def initialize(builder, class_to_mimic, options = {})
      super(builder)

      @class_to_mimic = class_to_mimic
      @include_super = options.fetch(:include_super) { true }

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
      class_to_mimic.instance_methods(include_super) - Object.instance_methods
    end
  end
end
