module Naught
  class ConversionsModule < Module
    def initialize(null_class, null_equivs)
      super() do
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
  end
end
