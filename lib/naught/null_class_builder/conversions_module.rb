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
          define_method(method_name, &mod.method(method_name))
        end
      end
    end

    def Null(object=:nothing_passed)
      case object
      when NullObjectTag then object
      when :nothing_passed, *null_equivs
        null_class.get(:caller => caller(1))
      else raise ArgumentError, "#{object.inspect} is not null!"
      end
    end

    def Maybe(object=nil, &block)
      object = block ? block.call : object
      case object
      when NullObjectTag then object
      when *null_equivs
        null_class.get(:caller => caller(1))
      else
        object
      end
    end

    def Just(object=nil, &block)
      object = block ? block.call : object
      case object
      when NullObjectTag, *null_equivs
        raise ArgumentError, "Null value: #{object.inspect}"
      else
        object
      end
    end

    def Actual(object=nil, &block)
      object = block ? block.call : object
      case object
      when NullObjectTag then nil
      else
        object
      end
    end

  end
end
