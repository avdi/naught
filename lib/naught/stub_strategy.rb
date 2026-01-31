module Naught
  # Strategies for stubbing methods on null objects
  #
  # @api private
  module StubStrategy
    # Stub that returns nil from any method
    module ReturnNil
      # Define a method that returns nil
      #
      # @param subject [Module, Class] target to define method on
      # @param name [Symbol] method name to define
      # @return [void]
      def self.apply(subject, name)
        subject.define_method(name) { |*, **, &| nil }
      end
    end

    # Stub that returns self from any method (black hole)
    module ReturnSelf
      # Define a method that returns self
      #
      # @param subject [Module, Class] target to define method on
      # @param name [Symbol] method name to define
      # @return [void]
      def self.apply(subject, name)
        subject.define_method(name) { |*, **, &| self }
      end
    end
  end
end
