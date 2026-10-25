# frozen_string_literal: true

# Null classes and inputs that the benchmarks share. Each worker builds
# them once, as it loads the benchmarks, so building them is never timed.

BasicNull = Naught.build
BlackHole = Naught.build(&:black_hole)
StringMimic = Naught.build { |config| config.mimic String }
PredicateNull = Naught.build { |config| config.predicates_return false }
ConvertibleNull = Naught.build do |config|
  config.define_explicit_conversions
  config.define_implicit_conversions
end
ManyEquivalentsNull = Naught.build do |config|
  config.null_equivalents.push(false, "", 0, [], {})
end
TraceableNull = Naught.build(&:traceable)
SingletonNull = Naught.build(&:singleton)
CallstackNull = Naught.build(&:callstack)
NullSafeNull = Naught.build(&:null_safe_proxy)

# An output for pebble that drops what it's given, so that every
# iteration writes to the same, empty, output.
class DiscardedOutput
  def puts(*) = nil
end

PebbleNull = Naught.build { |config| config.pebble DiscardedOutput.new }

# An object with a null class's conversion functions (Null(), Maybe(),
# Just() and Actual()), as code that includes them has.
def converter(null_class) = Object.new.extend(null_class::Conversions)

# A nested record for NullSafe() to walk, ending in nil.
Address = Struct.new(:city)
User = Struct.new(:address)
