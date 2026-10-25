# frozen_string_literal: true

require_relative "duel_helper"

duel "convert: Maybe(nil) to a null" do
  once { @converter = converter(BasicNull) }
  @converter.Maybe(nil)
end

duel "convert: Maybe(value) passes it through" do
  once { @converter = converter(BasicNull) }
  @converter.Maybe("value")
end

duel "convert: Maybe(value), many null equivalents" do
  once { @converter = converter(ManyEquivalentsNull) }
  @converter.Maybe("value")
end

duel "convert: Null() with no argument" do
  once { @converter = converter(BasicNull) }
  @converter.Null()
end

duel "convert: Just(value)" do
  once { @converter = converter(BasicNull) }
  @converter.Just("value")
end

duel "convert: Actual(null) to nil" do
  once do
    @converter = converter(BasicNull)
    @null = BasicNull.new
  end
  @converter.Actual(@null)
end

duel "convert: every explicit conversion" do
  once { @null = ConvertibleNull.new }
  @null.to_a
  @null.to_c
  @null.to_f
  @null.to_h
  @null.to_i
  @null.to_r
  @null.to_s
end

duel "convert: implicit, in Array#+ and String#+" do
  once { @null = ConvertibleNull.new }
  [[1] + @null, "a" + @null]
end

duel "null_safe: a chain of 3 through NullSafe()" do
  once do
    @converter = converter(NullSafeNull)
    @user = User.new(Address.new(nil))
  end
  @converter.NullSafe(@user).address.city.upcase
end
