require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Logs missing method calls and their call sites
      #
      # @api private
      class Pebble < ::Naught::NullClassBuilder::Command
        # Create a pebble command with optional output stream
        # @param builder [NullClassBuilder]
        # @param output [#puts] output stream for log lines
        # @return [void]
        # @api private
        def initialize(builder, output = $stdout)
          @builder = builder
          @output = output
        end

        # Install the logging method_missing hook
        #
        # @return [void]
        # @api private
        def call
          output = @output
          builder.defer_prepend_module do
            define_method(:method_missing) do |method_name, *args|
              pretty_args = args.map(&:inspect).join(", ").tr('"', "'")
              output.puts "#{method_name}(#{pretty_args}) from #{parse_caller}"
              self
            end

            define_method(:parse_caller) do
              stack = Kernel.caller(2)
              caller_info = stack.first

              extract_signature = ->(info) do
                match = info.match(/['`](.+)['`]$/)
                match && match[1]
              end

              split_signature = ->(signature) do
                if signature.include?(" in ")
                  signature.split(" in ", 2)
                else
                  [nil, signature]
                end
              end

              signature = extract_signature.call(caller_info)
              return caller_info unless signature

              block_info, method_part = split_signature.call(signature)
              method_name = method_part.split(/[#.]/).last

              if block_info&.start_with?("block") && !block_info.include?("levels")
                levels = 0
                stack.each do |info|
                  inner_signature = extract_signature.call(info)
                  break unless inner_signature

                  inner_block_info, inner_method_part = split_signature.call(inner_signature)
                  inner_method_name = inner_method_part.split(/[#.]/).last

                  if inner_block_info&.start_with?("block") && inner_method_name == method_name
                    levels += 1
                    next
                  end

                  break if inner_method_name == method_name
                end
                block_info = "block (#{levels} levels)" if levels > 1
              end

              block_info ? "#{block_info} #{method_name}" : method_name
            end
            private :parse_caller
          end
        end
      end
    end
  end
end
