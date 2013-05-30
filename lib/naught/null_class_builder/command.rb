module Naught
  class NullClassBuilder
    class Command
      def initialize(builder)
        @builder = builder
      end

      def call
        raise "Method #call should be overriden in child classes"
      end

      def defer(&block)
        @builder.defer(&block)
      end
    end
  end
end
