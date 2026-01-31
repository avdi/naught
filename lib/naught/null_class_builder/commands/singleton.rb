require "singleton"
require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Turns the null class into a Singleton
      #
      # @api private
      class Singleton < Command
        # Install Singleton behavior on the null class
        # @return [void]
        # @api private
        def call
          defer_class do |klass|
            klass.include(::Singleton)
            klass.singleton_class.undef_method(:get)
            klass.define_singleton_method(:get) { |*| instance }
            %i[dup clone].each { |name| klass.define_method(name) { self } }
          end
        end
      end
    end
  end
end
