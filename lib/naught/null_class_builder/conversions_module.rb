module Naught
  class ConversionsModule < Module
    attr_reader :null_class
    attr_reader :null_equivs

    def initialize(null_class, null_equivs)
      @null_class  = null_class
      @null_equivs = null_equivs
      mod          = self
      super() do
        %w[Null Maybe Just Actual].each do |method_name|
          # This is required to support Ruby 1.8 and earlier, which doesn't
          # allow define_method to take a block that takes a block argument.
          # See http://coderrr.wordpress.com/2008/10/29/using-define_method-with-blocks-in-ruby-18/
          define_method("__real__#{method_name}", &mod.method(method_name))
          class_eval <<-EOM
            def #{method_name}(*args, &block)
              __real__#{method_name}(block, *args)
            end
          EOM
        end
      end
    end

    def Null(block, object=:nothing_passed)
      case object
      when NullObjectTag then object
      when :nothing_passed, *null_equivs
        null_class.get(:caller => caller(1))
      else raise ArgumentError, "#{object.inspect} is not null!"
      end
    end

    def Maybe(block, object=nil)
      object = block ? block.call : object
      case object
      when NullObjectTag then object
      when *null_equivs
        null_class.get(:caller => caller(1))
      else
        object
      end
    end

    def Just(block, object=nil)
      object = block ? block.call : object
      case object
      when NullObjectTag, *null_equivs
        raise ArgumentError, "Null value: #{object.inspect}"
      else
        object
      end
    end

    def Actual(block, object=nil)
      object = block ? block.call : object
      case object
      when NullObjectTag then nil
      else
        object
      end
    end

  end
end
