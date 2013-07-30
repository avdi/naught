require 'naught/null_class_builder/command'

module Naught
  class NullClassBuilder
    module Commands
      class Pebble < ::Naught::NullClassBuilder::Command

        def initialize(builder, output=$stdout)
          @builder = builder
          @output = output
        end

        def call
          defer do |subject|
            subject.module_exec(@output) do |output|

              define_method(:method_missing) do |method_name, *args, &block|
                pretty_args = args.map(&:inspect).join(", ").gsub("\"", "'")
                output.puts "#{method_name}(#{pretty_args}) from #{parse_caller}"
                self
              end

              private

              def parse_caller
                caller = Kernel.caller(2).first
                method_name = caller.match(/\`([\w\s]+)/)
                method_name ? method_name[1] : caller
              end
            end
          end
        end
      end
    end
  end
end
