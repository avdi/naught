# frozen_string_literal: true

require_relative "duel_helper"

duel("new: a basic null") { BasicNull.new }

duel("new: a traceable null") { TraceableNull.new }

duel("new: a singleton's get") { SingletonNull.get }

duel "callstack: record a chain of 3 calls" do
  null = CallstackNull.new
  null.foo(1).bar.baz
end
