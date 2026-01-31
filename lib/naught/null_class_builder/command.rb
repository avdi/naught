module Naught
  class NullClassBuilder
    class Command
      attr_reader :builder

      def initialize(builder)
        @builder = builder
      end

      def call
        raise NotImplementedError, "Method #call should be overriden in child classes"
      end

      def defer(options = {}, &)
        @builder.defer(options, &)
      end
    end
  end
end
