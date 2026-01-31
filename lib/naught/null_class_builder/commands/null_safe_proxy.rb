require "naught/null_class_builder/command"

module Naught
  class NullClassBuilder
    module Commands
      # Enables null-safe proxy wrapping via the NullSafe() conversion function
      #
      # When enabled, the generated null class gains a NullSafe() function that
      # wraps any value in a proxy. The proxy intercepts all method calls and
      # wraps return values, replacing nil with the null object.
      #
      # @example Enable null-safe proxy
      #   NullObject = Naught.build do |b|
      #     b.null_safe_proxy
      #   end
      #   include NullObject::Conversions
      #
      #   NullSafe(obj).foo.bar.baz  #=> <null> if any call returns nil
      #
      # @api private
      class NullSafeProxy < ::Naught::NullClassBuilder::Command
        # Install the NullSafe conversion function
        #
        # @return [void]
        # @api private
        def call
          defer(class: true) do |subject|
            null_class = subject
            null_equivs = builder.null_equivalents

            proxy_class = Class.new(::Naught::BasicObject) do
              include ::Naught::NullSafeProxyTag

              define_method(:initialize) do |target|
                @target = target
              end

              define_method(:__target__) { @target }
            end

            proxy_class.define_method(:method_missing) do |method_name, *args, &block|
              result = @target.__send__(method_name, *args, &block)
              case result
              when ::Naught::NullObjectTag
                result
              when *null_equivs
                null_class.get
              else
                proxy_class.new(result)
              end
            end

            proxy_class.define_method(:respond_to?) do |method_name, include_private = false|
              @target.respond_to?(method_name, include_private)
            end

            proxy_class.define_method(:inspect) do
              "<null-safe-proxy(#{@target.inspect})>"
            end

            klass = proxy_class
            proxy_class.define_method(:class) { klass }

            subject.const_set(:NullSafeProxy, proxy_class)

            # Create a per-class Conversions module that extends Naught::Conversions
            conversions_mod = Module.new do
              include ::Naught::Conversions
            end
            conversions_mod.define_method(:NullSafe) do |object|
              case object
              when ::Naught::NullObjectTag
                object
              when *null_equivs
                null_class.get
              else
                proxy_class.new(object)
              end
            end

            # Replace the Conversions constant with our extended version
            subject.send(:remove_const, :Conversions)
            subject.const_set(:Conversions, conversions_mod)
          end
        end
      end
    end
  end
end
