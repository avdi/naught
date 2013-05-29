module Naught
  class NullClassBuilder
    # make sure this module exists
    module Commands
    end

    def initialize
      @interface_defined = false
      @base_class        = BasicObject
      @inspect_proc      = ->{ "<null>" }
      @stub_strategy     = :stub_method_returning_nil
      define_basic_methods
    end

    def interface_defined?
      @interface_defined
    end

    def customize(&customization_block)
      return unless customization_block
      customization_module.module_exec(self, &customization_block)
    end

    def customization_module
      @customization_module ||= Module.new
    end

    def null_equivalents
      @null_equivalents ||= [nil]
    end

    def generate_conversions_module(null_class)
      null_equivs = null_equivalents # get a local binding
      @conversions_module ||= Module.new do
        define_method(:Null) do |object=:nothing_passed|
          case object
          when NullObjectTag then object
          when :nothing_passed, *null_equivs
            null_class.get(caller: caller(1))
          else raise ArgumentError, "#{object.inspect} is not null!"
          end
        end

        define_method(:Maybe) do |object=nil, &block|
          object = block ? block.call : object
          case object
          when NullObjectTag then object
          when *null_equivs
            null_class.get(caller: caller(1))
          else
            object
          end
        end

        define_method(:Just) do |object=nil, &block|
          object = block ? block.call : object
          case object
          when NullObjectTag, *null_equivs
            raise ArgumentError, "Null value: #{object.inspect}"
          else
            object
          end
        end

        define_method(:Actual) do |object=nil, &block|
          object = block ? block.call : object
          case object
          when NullObjectTag then nil
          else
            object
          end
        end
      end
    end

    def generate_class
      generation_mod    = Module.new
      customization_mod = customization_module # get a local binding
      builder           = self
      @operations.each do |operation|
        operation.call(generation_mod)
      end
      null_class = Class.new(@base_class) do
        const_set :GeneratedMethods, generation_mod
        const_set :Customizations, customization_mod
        const_set :Conversions, builder.generate_conversions_module(self)

        include NullObjectTag
        include generation_mod
        include customization_mod
      end
      class_operations.each do |operation|
        operation.call(null_class)
      end
      null_class
    end

    def method_missing(method_name, *args, &block)
      command_name = command_name_for_method(method_name)
      if Commands.const_defined?(command_name)
        command_class = Commands.const_get(command_name)
        command_class.new(self, *args, &block).call
      else
        super
      end
    end

    def respond_to_missing?(method_name, *args)
      command_name = command_name_for_method(method_name)
      Commands.const_defined?(command_name) || super
    end

    ############################################################################
    # Builder API
    #
    # See also the contents of lib/naught/null_class_builder/commands
    ############################################################################
    def define_implicit_conversions
      defer do |subject|
        subject.module_eval do
          def to_ary; []; end
          def to_str; ''; end
        end
      end
    end

    def black_hole
      @stub_strategy = :stub_method_returning_self
    end

    def respond_to_any_message
      defer do |subject|
        subject.module_eval do
          def respond_to?(*)
            true
          end
        end
        stub_method(subject, :method_missing)
      end
      @interface_defined = true
    end

    def mimic(class_to_mimic, options={})
      include_super = options.fetch(:include_super) { true }
      @base_class   = root_class_of(class_to_mimic)
      @inspect_proc = -> { "<null:#{class_to_mimic}>" }
      defer do |subject|
        methods = class_to_mimic.instance_methods(include_super) -
          Object.instance_methods
        methods.each do |method_name|
          stub_method(subject, method_name)
        end
      end
      @interface_defined = true
    end

    def impersonate(class_to_impersonate, options={})
      mimic(class_to_impersonate, options)
      @base_class = class_to_impersonate
    end

    def traceable
      defer do |subject|
        subject.module_eval do
          attr_reader :__file__, :__line__

          def initialize(options={})
            backtrace = options.fetch(:caller) { Kernel.caller(4) }
            @__file__, line, _ = backtrace[0].split(':')
            @__line__ = line.to_i
          end
         end
      end
    end

    def defer(options={}, &deferred_operation)
      if options[:class]
        class_operations << deferred_operation
      else
        operations << deferred_operation
      end
    end

    def singleton
      defer(class: true) do |subject|
        require 'singleton'
        subject.module_eval do
          include Singleton
          def self.get(*)
            instance
          end
        end
      end
    end

    def define_basic_methods
      defer do |subject|
        # make local variable to be accessible to Class.new block
        inspect_proc = @inspect_proc
        subject.module_eval do
          define_method(:inspect, &inspect_proc)
          def initialize(*)
          end
        end
      end
      defer(class: true) do |subject|
        subject.module_eval do
          class << self
            alias get new
          end
          klass = self
          define_method(:class) { klass }
        end
      end
    end

    private

    def class_operations
      @class_operations ||= []
    end

    def operations
      @operations ||= []
    end

    def stub_method(subject, name)
      send(@stub_strategy, subject, name)
    end

    def stub_method_returning_nil(subject, name)
      subject.module_eval do
        define_method(name) {|*| nil }
      end
    end

    def stub_method_returning_self(subject, name)
      subject.module_eval do
        define_method(name) {|*| self }
      end
    end

    def command_name_for_method(method_name)
      command_name = method_name.to_s.
        gsub(/_(\w)/){ $1.upcase }.
        gsub(/\A(\w)/){ $1.upcase }
    end

    def root_class_of(klass)
      if klass.ancestors.include?(Object)
        Object
      else
        BasicObject
      end
    end

  end
end
