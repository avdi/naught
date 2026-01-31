require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Logs missing method calls and their call sites
      #
      # @api private
      class Pebble < Command
        # Create a pebble command with optional output stream
        #
        # @param builder [NullClassBuilder]
        # @param output [#puts] output stream for log lines
        # @api private
        def initialize(builder, output = $stdout)
          super(builder)
          @output = output
        end

        # Install the logging method_missing hook
        # @return [void]
        # @api private
        def call
          output = @output
          defer_prepend_module do
            define_method(:method_missing) do |method_name, *args|
              pretty_args = args.map(&:inspect).join(", ").tr('"', "'")
              caller_desc = Naught::CallerInfo.format_caller_for_pebble(Kernel.caller(1))
              output.puts "#{method_name}(#{pretty_args}) from #{caller_desc}"
              self
            end
          end
        end
      end
    end
  end
end
