require "spec_helper"

RSpec.describe Naught do
  describe "Maybe()" do
    include ConvertableNull::Conversions

    specify "given nil, returns a null object" do
      expect(Maybe(nil).class).to be(ConvertableNull)
    end

    specify "given a null object, returns the same null object" do
      null = ConvertableNull.get
      expect(Maybe(null)).to be(null)
    end

    specify "given anything in null_equivalents, returns a null object" do
      expect(Maybe("").class).to be(ConvertableNull)
    end

    specify "given false, returns false unchanged" do
      expect(Maybe(false)).to be(false)
    end

    specify "given a string, returns the string unchanged" do
      str = "hello"
      expect(Maybe(str)).to be(str)
    end

    it "generates null objects with trace info for file" do
      null, = Maybe(), __LINE__ # rubocop:disable Style/ParallelAssignment
      expect(null.__file__).to eq(__FILE__)
    end

    it "generates null objects with trace info for line" do
      null, line = Maybe(), __LINE__ # rubocop:disable Style/ParallelAssignment
      expect(null.__line__).to eq(line)
    end

    it "returns null object when block yields nil" do
      expect(Maybe { nil }.class).to eq(ConvertableNull)
    end

    it "returns block result when block yields non-nullish value" do
      expect(Maybe { "foo" }).to eq("foo")
    end
  end
end
