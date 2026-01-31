require "naught/version"
require "naught/null_class_builder"
require "naught/null_class_builder/commands"

# Top-level namespace for Naught null object helpers
#
# @api public
module Naught
  # Build a null object class using the builder DSL
  #
  # @example Create a basic null object class
  #   NullObject = Naught.build
  #   null = NullObject.new
  #   null.foo  #=> nil
  #
  # @example Create a black hole null object
  #   BlackHole = Naught.build do |b|
  #     b.black_hole
  #   end
  #   BlackHole.new.foo.bar.baz  #=> <null>
  #
  # @yieldparam builder [Naught::NullClassBuilder] builder DSL instance
  # @yieldreturn [void]
  # @return [Class] generated null class
  # @api public
  def self.build(&)
    builder = NullClassBuilder.new
    builder.customize(&)
    builder.generate_class
  end

  # Marker module mixed into generated null objects
  #
  # @api public
  module NullObjectTag
  end

  # Marker module for null-safe proxy wrappers
  #
  # @api public
  module NullSafeProxyTag
  end
end
