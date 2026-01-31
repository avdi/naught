require "naught/version"
require "naught/null_class_builder"
require "naught/null_class_builder/commands"

module Naught
  def self.build(&)
    builder = NullClassBuilder.new
    builder.customize(&)
    builder.generate_class
  end

  module NullObjectTag
  end
end
