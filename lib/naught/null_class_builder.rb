require "naught/basic_object"
require "naught/conversions"
require "naught/stub_strategy"

module Naught
  # Builds customized null object classes via a small DSL
  #
  # @api public
  class NullClassBuilder
    # Namespace for builder command classes
    # @api private
    module Commands; end

    # The base class for generated null objects
    #
    # @return [Class] base class for generated null objects
    # @example
    #   builder.base_class #=> Naught::BasicObject
    attr_accessor :base_class

    # The inspect implementation for generated null objects
    #
    # @return [Proc] inspect implementation for generated null objects
    # @example
    #   builder.inspect_proc.call #=> "<null>"
    attr_accessor :inspect_proc

    # Whether a method-missing interface has been defined
    #
    # @return [Boolean] whether a method-missing interface has been defined
    # @example
    #   builder.interface_defined #=> false
    attr_accessor :interface_defined

    # @!method interface_defined?
    #   Check if a method-missing interface has been defined
    #   @return [Boolean] true if interface is defined
    #   @example
    #     builder.interface_defined? #=> false
    alias_method :interface_defined?, :interface_defined

    # Create a new builder with default configuration
    # @api private
    def initialize
      @interface_defined = false
      @base_class = Naught::BasicObject
      @inspect_proc = -> { "<null>" }
      @stub_strategy = StubStrategy::ReturnNil
      define_basic_methods
    end

    # Apply a customization block to this builder
    #
    # @yieldparam builder [NullClassBuilder] builder instance
    # @return [void]
    # @example
    #   builder.customize { |b| b.black_hole }
    def customize(&)
      customization_module.module_exec(self, &) if block_given?
    end

    # Returns the module that holds customization methods
    #
    # @return [Module] module that holds customization methods
    # @example
    #   builder.customization_module #=> #<Module:0x...>
    def customization_module = @customization_module ||= Module.new

    # Returns the list of values treated as null-equivalent
    #
    # @return [Array<Object>] values treated as null-equivalent
    # @example
    #   builder.null_equivalents #=> [nil]
    def null_equivalents = @null_equivalents ||= [nil]

    # Generate the null object class based on queued operations
    #
    # @return [Class] generated null class
    # @example
    #   NullClass = builder.generate_class
    def generate_class
      respond_to_any_message unless interface_defined?

      generation_mod = Module.new
      apply_operations(operations, generation_mod)

      null_class = build_null_class(generation_mod)
      apply_operations(class_operations, null_class)

      null_class
    end

    # Builder API - see also lib/naught/null_class_builder/commands

    # Configure method stubs to return self (black hole behavior)
    #
    # @see https://github.com/avdi/naught/issues/72
    # @return [void]
    # @example
    #   builder.black_hole
    def black_hole
      @stub_strategy = StubStrategy::ReturnSelf
      # Prepend marshal methods to avoid infinite recursion with method_missing
      defer_prepend_module do
        define_method(:marshal_dump) { nil }
        define_method(:marshal_load) { |*| nil }
      end
    end

    # Make null objects respond to any message
    #
    # @return [void]
    # @example
    #   builder.respond_to_any_message
    def respond_to_any_message
      defer(prepend: true) do |subject|
        subject.define_method(:respond_to?) { |*, **| true }
        stub_method(subject, :method_missing)
      end
      @interface_defined = true
    end

    # Queue a deferred operation to be applied during class generation
    #
    # @param options [Hash] :class for class-level, :prepend to add at front
    # @yieldparam subject [Module, Class] target of the operation
    # @return [void]
    # @example
    #   builder.defer { |subject| subject.define_method(:foo) { "bar" } }
    def defer(options = {}, &operation)
      target = options[:class] ? class_operations : operations
      options[:prepend] ? target.unshift(operation) : target.push(operation)
    end

    # Prepend a module generated from the given block
    #
    # @return [void]
    # @example
    #   builder.defer_prepend_module { define_method(:foo) { "bar" } }
    def defer_prepend_module(&)
      prepend_modules << Module.new(&)
    end

    # Stub a method using the current stub strategy
    #
    # @param subject [Module, Class] target to define method on
    # @param name [Symbol] method name to stub
    # @return [void]
    # @example
    #   builder.stub_method(some_module, :foo)
    def stub_method(subject, name)
      @stub_strategy.apply(subject, name)
    end

    # Dispatch builder DSL calls to command classes
    # @return [void]
    # @api private
    def method_missing(method_name, *args, &)
      command_class = lookup_command(method_name)
      command_class ? command_class.new(self, *args, &).call : super
    end

    # Check if builder responds to a DSL command
    #
    # @param method_name [Symbol] method name to check
    # @param include_private [Boolean] whether to include private methods
    # @return [Boolean] true if method_name maps to a known command
    # @api private
    def respond_to_missing?(method_name, include_private = false)
      !lookup_command(method_name).nil? || super
    rescue NameError
      super
    end

    private

    # Build the null object class with all configured modules
    #
    # @param generation_mod [Module] module containing generated methods
    # @return [Class] the null object class
    # @api private
    def build_null_class(generation_mod)
      customization_mod = customization_module
      null_equivs = null_equivalents
      modules_to_prepend = prepend_modules

      Class.new(@base_class) do
        const_set :GeneratedMethods, generation_mod
        const_set :Customizations, customization_mod

        conversions_mod = Module.new { include Conversions }
        Conversions.configure(conversions_mod, null_class: self, null_equivs: null_equivs)
        const_set :Conversions, conversions_mod

        include NullObjectTag
        include generation_mod
        include customization_mod

        modules_to_prepend.each { |mod| prepend mod }
      end
    end

    # Define the basic methods required by all null objects
    #
    # @return [void]
    # @api private
    def define_basic_methods
      define_basic_instance_methods
      define_basic_class_methods
    end

    # Apply deferred operations to the target module or class
    #
    # @param ops [Array<Proc>] operations to apply
    # @param target [Module, Class] target for the operations
    # @return [void]
    # @api private
    def apply_operations(ops, target)
      ops.each { |op| op.call(target) }
    end

    # Define the basic instance methods for null objects
    #
    # @return [void]
    # @api private
    def define_basic_instance_methods
      builder = self
      defer do |subject|
        subject.define_method(:inspect, &builder.inspect_proc)
        subject.define_method(:initialize) { |*, **, &| }
      end
    end

    # Define the basic class methods for null objects
    #
    # @return [void]
    # @api private
    def define_basic_class_methods
      defer(class: true) do |klass|
        klass.define_singleton_method(:get) do |*args, **kwargs, &block|
          kw = kwargs #: Hash[Symbol, untyped]
          new(*args, **kw, &block)
        end
        klass.define_method(:class) { klass }
      end
    end

    # Returns the list of class-level operations
    #
    # @return [Array<Proc>] class-level operations
    # @api private
    def class_operations = @class_operations ||= []

    # Returns the list of instance-level operations
    #
    # @return [Array<Proc>] instance-level operations
    # @api private
    def operations = @operations ||= []

    # Returns the list of modules to prepend
    #
    # @return [Array<Module>] modules to prepend to the null class
    # @api private
    def prepend_modules = @prepend_modules ||= []

    # Look up a command class by method name
    #
    # @param method_name [Symbol] method name to look up
    # @return [Class, nil] command class if found, nil otherwise
    # @api private
    def lookup_command(method_name)
      command_name = camelize(method_name)
      Commands.const_get(command_name) if Commands.const_defined?(command_name)
    end

    # Convert a snake_case method name to CamelCase
    #
    # @param name [Symbol, String] the name to convert
    # @return [String] the CamelCase version
    # @api private
    def camelize(name) = name.to_s.gsub(/(?:^|_)([a-z])/) { ::Regexp.last_match(1).upcase }
  end
end
