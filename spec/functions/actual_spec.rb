require "spec_helper"

RSpec.describe Naught do
  describe "Actual()" do
    include ConvertableNull::Conversions

    specify "given a null object, returns nil" do
      null = ConvertableNull.get
      expect(Actual(null)).to be_nil
    end

    specify "given false, returns false unchanged" do
      expect(Actual(false)).to be(false)
    end

    specify "given a string, returns the string unchanged" do
      str = "hello"
      expect(Actual(str)).to be(str)
    end

    specify "given nil, returns nil" do
      expect(Actual(nil)).to be_nil
    end

    it "returns nil when block yields null object" do
      expect(Actual { ConvertableNull.new }).to be_nil
    end

    it "returns block result when block yields non-null" do
      expect(Actual { "foo" }).to eq("foo")
    end
  end
end
