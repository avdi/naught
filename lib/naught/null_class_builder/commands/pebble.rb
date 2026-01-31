require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      class Pebble < ::Naught::NullClassBuilder::Command
        # Ruby 3.4+: "path:line:in 'Class#method'" or "path:line:in 'block in Class#method'"
        # Ruby <3.4: "path:line:in `method'" or "path:line:in `block in method'"
        CALLER_RE = /'(?:(.+) in )?(?:[\w:]+#)?(\w+)'$|`(?:(.+) in )?(\w+)'$/

        def initialize(builder, output = $stdout)
          @builder = builder
          @output = output
        end

        def call
          defer do |subject|
            subject.module_exec(@output) do |output|
              define_method(:method_missing) do |method_name, *args|
                pretty_args = args.map(&:inspect).join(", ").tr('"', "'")
                output.puts "#{method_name}(#{pretty_args}) from #{parse_caller}"
                self
              end

              define_method(:parse_caller) do
                caller_info = Kernel.caller(2).first
                match = caller_info.match(Pebble::CALLER_RE)
                return caller_info unless match

                block_info = match[1] || match[3]
                method_name = match[2] || match[4]
                block_info ? "#{block_info} #{method_name}" : method_name
              end
              private :parse_caller
            end
          end
        end
      end
    end
  end
end
