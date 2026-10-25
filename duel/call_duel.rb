# frozen_string_literal: true

require_relative "duel_helper"

duel "call: an unknown method" do
  once { @null = BasicNull.new }
  @null.foo
end

duel "call: an unknown method with arguments" do
  once { @null = BasicNull.new }
  @null.foo(1, "two", three: 3)
end

duel "call: a mimicked method" do
  once { @null = StringMimic.new }
  @null.upcase
end

duel "call: a predicate with predicates_return" do
  once { @null = PredicateNull.new }
  @null.valid?
end

duel "call: respond_to?" do
  once { @null = BasicNull.new }
  @null.respond_to?(:foo)
end

duel "black_hole: a chain of 3 calls" do
  once { @null = BlackHole.new }
  @null.foo.bar.baz
end

duel "black_hole: a chain of 20 calls" do
  once { @null = BlackHole.new }
  @null.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t
end

duel "pebble: log a call" do
  once { @null = PebbleNull.new }
  @null.foo(1, "two")
end
