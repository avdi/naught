module Naught

  module ConversionsModule

    def Null(object = :nothing_passed)
      case object
      when NullObjectTag then object
      when :nothing_passed, *null_equivs
        null_class.get(caller: caller(1))
      else raise ArgumentError, "#{object.inspect} is not null!"
      end
    end

    def Maybe(object = nil, &block)
      object = block ? block.call : object
      case object
      when NullObjectTag then object
      when *null_equivs
        null_class.get(caller: caller(1))
      else
        object
      end
    end

    def Just(object = nil, &block)
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

    class << self

      def build(null_equivs, null_class)
        Module.new do
          define_method(:null_equivs) { null_equivs }
          define_method(:null_class)  { null_class  }
          include ::Naught::ConversionsModule
        end
      end

    end

  end

end