require "naught/basic_object"
require "naught/conversions"

module Naught
  # Builds customized null object classes via a small DSL
  #
  # @api public
  class NullClassBuilder
    # Namespace for builder command classes
    #
    # @api private
    module Commands
    end

    # Base class for generated null objects
    #
    # @example Get the base class
    #   builder.base_class  #=> Naught::BasicObject
    #
    # @return [Class]
    # @api semipublic
    attr_accessor :base_class

    # Inspect implementation for generated null objects
    #
    # @example Get the inspect proc
    #   builder.inspect_proc.call  #=> "<null>"
    #
    # @return [Proc]
    # @api semipublic
    attr_accessor :inspect_proc

    # Whether a method-missing interface has been defined
    #
    # @example Check if interface is defined
    #   builder.interface_defined?  #=> false
    #
    # @return [Boolean]
    # @api semipublic
    attr_accessor :interface_defined
    alias_method :interface_defined?, :interface_defined

    # Create a new builder with default configuration
    #
    # @return [void]
    # @api private
    def initialize
      @interface_defined = false
      @base_class = Naught::BasicObject
      @inspect_proc = -> { "<null>" }
      @stub_strategy = :stub_method_returning_nil
      define_basic_methods
    end

    # Apply a customization block to this builder
    #
    # @example Customize the builder
    #   builder.customize { |b| b.black_hole }
    #
    # @param customization_block [Proc]
    # @yieldparam builder [NullClassBuilder] builder instance
    # @yieldreturn [void]
    # @return [void]
    # @api semipublic
    def customize(&customization_block)
      return unless customization_block

      customization_module.module_exec(self, &customization_block)
    end

    # Module that holds customization methods
    #
    # @example Access the customization module
    #   builder.customization_module  #=> Module
    #
    # @return [Module]
    # @api semipublic
    def customization_module
      @customization_module ||= Module.new
    end

    # Values treated as null-equivalent
    #
    # @example Get the null equivalents
    #   builder.null_equivalents  #=> [nil]
    #
    # @return [Array<Object>]
    # @api public
    def null_equivalents
      @null_equivalents ||= [nil]
    end

    # Generate the null object class based on queued operations
    #
    # @example Generate a null class
    #   klass = builder.generate_class
    #   klass.new  #=> <null>
    #
    # @return [Class] generated null class
    # @api semipublic
    def generate_class
      respond_to_any_message unless interface_defined?
      generation_mod = Module.new
      customization_mod = customization_module # get a local binding
      builder = self
      modules_to_prepend = prepend_modules

      apply_operations(operations, generation_mod)

      null_class = Class.new(@base_class) do
        const_set :GeneratedMethods, generation_mod
        const_set :Customizations, customization_mod
        const_set :NULL_EQUIVS, builder.null_equivalents
        include Conversions

        remove_const :NULL_EQUIVS
        Conversions.instance_methods.each do |instance_method|
          undef_method(instance_method)
        end
        const_set :Conversions, Conversions

        include NullObjectTag
        include generation_mod
        include customization_mod

        modules_to_prepend.each { |mod| prepend mod }
      end

      apply_operations(class_operations, null_class)

      null_class
    end

    ############################################################################
    # Builder API
    #
    # See also the contents of lib/naught/null_class_builder/commands
    ############################################################################

    # Configure method stubs to return self (black hole behavior)
    #
    # @example Enable black hole behavior
    #   Naught.build { |b| b.black_hole }
    #
    # @return [void]
    # @api public
    def black_hole
      @stub_strategy = :stub_method_returning_self
    end

    # Make null objects respond to any message and stub method_missing
    #
    # @example Make null respond to anything
    #   Naught.build { |b| b.respond_to_any_message }
    #
    # @return [void]
    # @api public
    def respond_to_any_message
      defer(prepend: true) do |subject|
        subject.module_eval do
          def respond_to?(*)
            true
          end
        end
        stub_method(subject, :method_missing)
      end
      @interface_defined = true
    end

    # Queue a deferred operation to be applied during class generation
    #
    # @example Defer a method definition
    #   builder.defer { |mod| mod.define_method(:foo) { :bar } }
    #
    # @param options [Hash] operation options
    # @param deferred_operation [Proc]
    # @yieldparam subject [Module, Class] target of the operation
    # @yieldreturn [void]
    # @return [void]
    # @api semipublic
    def defer(options = {}, &deferred_operation)
      list = options[:class] ? class_operations : operations
      if options[:prepend]
        list.unshift(deferred_operation)
      else
        list << deferred_operation
      end
    end

    # Prepend a module generated from the given block
    #
    # @example Prepend a custom module
    #   builder.defer_prepend_module { define_method(:foo) { :bar } }
    #
    # @param block [Proc]
    # @yield [void]
    # @yieldreturn [void]
    # @return [void]
    # @api semipublic
    def defer_prepend_module(&block)
      mod = Module.new(&block)
      prepend_modules << mod
    end

    # Stub a method using the current stub strategy
    #
    # @example Stub a method
    #   builder.stub_method(mod, :foo)
    #
    # @param subject [Module, Class]
    # @param name [Symbol]
    # @return [void]
    # @api semipublic
    def stub_method(subject, name)
      send(@stub_strategy, subject, name)
    end

    # Dispatch builder DSL calls to command classes
    #
    # @param method_name [Symbol]
    # @param args [Array<Object>]
    # @param block [Proc, nil]
    # @return [Object]
    # @api private
    def method_missing(method_name, *args, &block)
      command_name = command_name_for_method(method_name)
      if Commands.const_defined?(command_name)
        command_class = Commands.const_get(command_name)
        command_class.new(self, *args, &block).call
      else
        super
      end
    end

    # Report supported DSL methods
    #
    # @param method_name [Symbol]
    # @param include_private [Boolean]
    # @return [Boolean]
    # @api private
    def respond_to_missing?(method_name, include_private = false)
      command_name = command_name_for_method(method_name)
      Commands.const_defined?(command_name) ||
        super
    rescue NameError
      super
    end

    private

    # Define standard instance and class methods
    # @return [void]
    # @api private
    def define_basic_methods
      define_basic_instance_methods
      define_basic_class_methods
    end

    # Apply deferred operations to a module or class
    # @param operations [Array<Proc>] operations to apply
    # @param module_or_class [Module, Class] target
    # @return [void]
    # @api private
    def apply_operations(operations, module_or_class)
      operations.each do |operation|
        operation.call(module_or_class)
      end
    end

    # Define inspect and initialize on the generated class
    # @return [void]
    # @api private
    def define_basic_instance_methods
      defer do |subject|
        subject.module_exec(@inspect_proc) do |inspect_proc|
          define_method(:inspect, &inspect_proc)
          def initialize(*)
          end
        end
      end
    end

    # Define class-level helpers like .get
    # @return [void]
    # @api private
    def define_basic_class_methods
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

    # Deferred operations applied to the class itself
    # @return [Array<Proc>]
    # @api private
    def class_operations
      @class_operations ||= []
    end

    # Deferred operations applied to the generation module
    # @return [Array<Proc>]
    # @api private
    def operations
      @operations ||= []
    end

    # Modules to prepend to the generated class
    # @return [Array<Module>]
    # @api private
    def prepend_modules
      @prepend_modules ||= []
    end

    # Create a stub returning nil
    # @param subject [Module, Class]
    # @param name [Symbol]
    # @return [void]
    # @api private
    def stub_method_returning_nil(subject, name)
      subject.module_eval do
        define_method(name) { |*| nil }
      end
    end

    # Create a stub returning self
    # @param subject [Module, Class]
    # @param name [Symbol]
    # @return [void]
    # @api private
    def stub_method_returning_self(subject, name)
      subject.module_eval do
        define_method(name) { |*| self }
      end
    end

    # Convert a method name to a command class name
    # @param method_name [Symbol]
    # @return [String]
    # @api private
    def command_name_for_method(method_name)
      method_name.to_s.gsub(/(?:^|_)([a-z])/) { Regexp.last_match[1].upcase }
    end
  end
end
