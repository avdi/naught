require "spec_helper"

RSpec.describe Naught do
  describe "Just()" do
    include ConvertableNull::Conversions

    specify "passes false through" do
      expect(Just(false)).to be(false)
    end

    specify "passes strings through" do
      str = "hello"
      expect(Just(str)).to be(str)
    end

    specify "rejects nil" do
      expect { Just(nil) }.to raise_error(ArgumentError)
    end

    specify "rejects empty string" do
      expect { Just("") }.to raise_error(ArgumentError)
    end

    specify "rejects null objects" do
      expect { Just(ConvertableNull.get) }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError when block yields nil" do
      expect { Just { nil }.class }.to raise_error(ArgumentError)
    end

    it "returns block result when block yields non-nullish value" do
      expect(Just { "foo" }).to eq("foo")
    end
  end
end
