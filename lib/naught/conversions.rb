module Naught
  # Helper conversion API available on generated null classes
  #
  # @api public
  module Conversions
    # Capture the generated null class when the module is included
    #
    # @param null_class [Class] generated null class
    # @return [void]
    # @api private
    def self.included(null_class)
      unless class_variable_defined?(:@@included) && @@included
        @@null_class = null_class
        @@null_equivs = null_class::NULL_EQUIVS
        @@included = true
      end
      super
    end

    # Return a null object for +object+ if it is null-equivalent
    #
    # @example Convert nil to a null object
    #   Null(nil)  #=> <null>
    #
    # @example Raise on non-null value
    #   Null(42)  #=> ArgumentError
    #
    # @param object [Object] candidate object
    # @return [Object] a null object
    # @raise [ArgumentError] if +object+ is not null-equivalent
    # @api public
    def Null(object = :nothing_passed)
      case object
      when NullObjectTag
        object
      when :nothing_passed, *@@null_equivs
        @@null_class.get(caller: caller(1))
      else
        raise ArgumentError, "#{object.inspect} is not null!"
      end
    end

    # Return a null object for null-equivalent values, otherwise the value
    #
    # @example Convert nil to null
    #   Maybe(nil)  #=> <null>
    #
    # @example Pass through non-null values
    #   Maybe(42)  #=> 42
    #
    # @param object [Object] candidate object
    # @yieldreturn [Object] optional lazy value
    # @return [Object] null object or original value
    # @api public
    def Maybe(object = nil)
      object = yield if block_given?
      case object
      when NullObjectTag
        object
      when *@@null_equivs
        @@null_class.get(caller: caller(1))
      else
        object
      end
    end

    # Return the value if not null-equivalent, otherwise raise
    #
    # @example Return non-null value
    #   Just(42)  #=> 42
    #
    # @example Raise on nil
    #   Just(nil)  #=> ArgumentError
    #
    # @param object [Object] candidate object
    # @yieldreturn [Object] optional lazy value
    # @return [Object] original value
    # @raise [ArgumentError] if value is null-equivalent
    # @api public
    def Just(object = nil)
      object = yield if block_given?
      case object
      when NullObjectTag, *@@null_equivs
        raise ArgumentError, "Null value: #{object.inspect}"
      else
        object
      end
    end

    # Return +nil+ for null objects, otherwise return the value
    #
    # @example Convert null object to nil
    #   Actual(NullObject.new)  #=> nil
    #
    # @example Pass through regular values
    #   Actual(42)  #=> 42
    #
    # @param object [Object] candidate object
    # @yieldreturn [Object] optional lazy value
    # @return [Object, nil] actual value or nil
    # @api public
    def Actual(object = nil)
      object = yield if block_given?
      case object
      when NullObjectTag
        nil
      else
        object
      end
    end
  end
end
