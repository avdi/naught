require "naught/version"
require 'naught/null_class_builder'
require 'naught/null_class_builder/commands/define_explicit_conversions'

module Naught
  def self.build(&customization_block)
    builder = NullClassBuilder.new
    builder.customize(&customization_block)
    unless builder.interface_defined?
      builder.respond_to_any_message
    end
    builder.generate_class
  end
  module NullObjectTag
  end
end
