module Naught
  # Helper conversion API available on generated null classes
  #
  # This module is designed to be configured per null class via
  # {Conversions.configure}. Each generated null class gets its
  # own configured version of these conversion functions.
  #
  # @api public
  module Conversions
    # Sentinel value for no argument passed
    NOTHING_PASSED = Object.new.freeze
    private_constant :NOTHING_PASSED

    class << self
      # Configure a Conversions module for a specific null class
      #
      # @param mod [Module] module to configure
      # @param null_class [Class] the generated null class
      # @param null_equivs [Array] values treated as null-equivalent
      # @return [void]
      # @api private
      def configure(mod, null_class:, null_equivs:)
        mod.define_method(:__null_class__) { null_class }
        mod.define_method(:__null_equivs__) { null_equivs }
        mod.send(:private, :__null_class__, :__null_equivs__)
      end
    end

    # Return a null object for +object+ if it is null-equivalent
    #
    # @example
    #   include MyNullObject::Conversions
    #   Null()       #=> <null>
    #   Null(nil)    #=> <null>
    #
    # @param object [Object] candidate object
    # @return [Object] a null object
    # @raise [ArgumentError] if +object+ is not null-equivalent
    def Null(object = NOTHING_PASSED)
      return object if null_object?(object)
      return make_null(1) if null_equivalent?(object, include_nothing: true)

      raise ArgumentError, "Null() requires a null-equivalent value, " \
                           "got #{object.class}: #{object.inspect}"
    end

    # Return a null object for null-equivalent values, otherwise the value
    #
    # @example
    #   Maybe(nil)        #=> <null>
    #   Maybe("hello")    #=> "hello"
    #
    # @param object [Object] candidate object
    # @yieldreturn [Object] optional lazy value
    # @return [Object] null object or original value
    def Maybe(object = nil)
      object = yield if block_given?
      return object if null_object?(object)
      return make_null(1) if null_equivalent?(object)

      object
    end

    # Return the value if not null-equivalent, otherwise raise
    #
    # @example
    #   Just("hello")  #=> "hello"
    #   Just(nil)      # raises ArgumentError
    #
    # @param object [Object] candidate object
    # @yieldreturn [Object] optional lazy value
    # @return [Object] original value
    # @raise [ArgumentError] if value is null-equivalent
    def Just(object = nil)
      object = yield if block_given?
      if null_object?(object) || null_equivalent?(object)
        raise ArgumentError, "Just() requires a non-null value, got: #{object.inspect}"
      end

      object
    end

    # Return +nil+ for null objects, otherwise return the value
    #
    # @example
    #   Actual(null)     #=> nil
    #   Actual("hello")  #=> "hello"
    #
    # @param object [Object] candidate object
    # @yieldreturn [Object] optional lazy value
    # @return [Object, nil] actual value or nil
    def Actual(object = nil)
      object = yield if block_given?
      null_object?(object) ? nil : object
    end

    private

    # Check if an object is a null object
    #
    # @param object [Object] the object to check
    # @return [Boolean] true if the object is a null object
    # @api private
    def null_object?(object)
      NullObjectTag === object
    end

    # Check if an object is null-equivalent (nil or custom null equivalents)
    #
    # @param object [Object] the object to check
    # @param include_nothing [Boolean] whether to treat NOTHING_PASSED as null-equivalent
    # @return [Boolean] true if the object is null-equivalent
    # @api private
    def null_equivalent?(object, include_nothing: false)
      return true if include_nothing && object == NOTHING_PASSED

      __null_equivs__.any? { |equiv| equiv === object }
    end

    # Create a new null object instance
    #
    # @param caller_offset [Integer] additional stack frames to skip
    # @return [Object] a new null object
    # @api private
    def make_null(caller_offset)
      __null_class__.get(caller: caller(caller_offset + 1))
    end
  end
end
