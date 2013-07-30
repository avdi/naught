require 'naught/null_class_builder/command'

module Naught
  class NullClassBuilder
    module Commands
      class Pebble < ::Naught::NullClassBuilder::Command

        def call
          defer do |subject|
            subject.module_eval do
              def method_missing(name, *args)
                pretty_args = args.map(&:inspect).join(", ").gsub("\"", "'")
                Kernel.p "#{name}(#{pretty_args}) from #{parse_caller}"
                self
              end

              private

              def parse_caller
                caller = Kernel.caller(2).first
                method_name = caller.match(/\`(\w+)/)
                method_name ? method_name[1] : caller
              end
            end
          end
        end
      end
    end
  end
end