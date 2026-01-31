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
      #   NullObject = Naught.build do |config|
      #     config.null_safe_proxy
      #   end
      #
      #   include NullObject::Conversions
      #
      #   user = nil
      #   NullSafe(user).name.upcase      # => <null>
      #
      #   user = OpenStruct.new(name: nil)
      #   NullSafe(user).name.upcase      # => <null>
      #
      #   user = OpenStruct.new(name: "Bob")
      #   NullSafe(user).name.upcase      # => "BOB"
      #
      # @api private
      class NullSafeProxy < Command
        # Install the NullSafe conversion function
        # @return [void]
        # @api private
        def call
          null_equivs = builder.null_equivalents
          defer_class do |null_class|
            proxy_class = build_proxy_class(null_class, null_equivs)
            null_class.const_set(:NullSafeProxy, proxy_class)
            install_null_safe_conversion(null_class, proxy_class, null_equivs)
          end
        end

        private

        # Build the proxy class that wraps objects for null-safe access
        #
        # @param null_class [Class] the null object class
        # @param null_equivs [Array<Object>] values treated as null-equivalent
        # @return [Class] the proxy class
        # @api private
        def build_proxy_class(null_class, null_equivs)
          Class.new(::Naught::BasicObject) do
            include ::Naught::NullSafeProxyTag

            define_method(:initialize) { |target| @target = target }
            define_method(:__target__) { @target }
            define_method(:respond_to?) { |method_name, include_private = false| @target.respond_to?(method_name, include_private) }
            define_method(:inspect) { "<null-safe-proxy(#{@target.inspect})>" }

            define_method(:method_missing) do |method_name, *args, &block|
              result = @target.__send__(method_name, *args, &block)
              case result
              when ::Naught::NullObjectTag then result
              when *null_equivs then null_class.get
              else self.class.new(result)
              end
            end

            klass = self
            define_method(:class) { klass }
          end
        end

        # Install the NullSafe conversion method on the Conversions module
        #
        # @param null_class [Class] the null object class
        # @param proxy_class [Class] the proxy class
        # @param null_equivs [Array<Object>] values treated as null-equivalent
        # @return [void]
        # @api private
        def install_null_safe_conversion(null_class, proxy_class, null_equivs)
          null_class.const_get(:Conversions).define_method(:NullSafe) do |object|
            case object
            when ::Naught::NullObjectTag then object
            when *null_equivs then null_class.get
            else proxy_class.new(object)
            end
          end
        end
      end
    end
  end
end
