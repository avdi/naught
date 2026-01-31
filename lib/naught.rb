require "naught/version"
require "naught/caller_info"
require "naught/null_class_builder"
require "naught/null_class_builder/commands"

# Top-level namespace for Naught null object helpers
#
# @example Create a basic null object class
#   NullObject = Naught.build
#   null = NullObject.new
#   null.foo  #=> nil
#
# @example Create a black hole null object
#   BlackHole = Naught.build(&:black_hole)
#   BlackHole.new.foo.bar.baz  #=> <null>
#
# @api public
module Naught
  # Build a null object class using the builder DSL
  #
  # @example
  #   NullObject = Naught.build { |b| b.black_hole }
  #
  # @yieldparam builder [Naught::NullClassBuilder] builder DSL instance
  # @return [Class] generated null class
  def self.build(&)
    builder = NullClassBuilder.new
    builder.customize(&)
    builder.generate_class
  end

  # Marker module mixed into generated null objects
  module NullObjectTag; end

  # Marker module for null-safe proxy wrappers
  module NullSafeProxyTag; end
end
