# frozen_string_literal: true

require_relative "duel_helper"

duel("build: a basic null class") { Naught.build }

duel("build: a black hole") { Naught.build(&:black_hole) }

duel "build: mimic String" do
  Naught.build { |config| config.mimic String }
end

duel "build: mimic an example Hash" do
  once { @example = {name: "Ada", email: "ada@example.com"} }
  example = @example
  Naught.build { |config| config.mimic example: example }
end

duel "build: with every command" do
  Naught.build do |config|
    config.black_hole
    config.define_explicit_conversions
    config.define_implicit_conversions
    config.predicates_return false
    config.traceable
    config.callstack
    config.null_safe_proxy
    config.singleton
  end
end
