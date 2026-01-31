require "spec_helper"

RSpec.describe Naught do
  describe "Null()" do
    include ConvertableNull::Conversions

    specify "given no input, returns a null object" do
      expect(Null().class).to be(ConvertableNull)
    end

    specify "given nil, returns a null object" do
      expect(Null(nil).class).to be(ConvertableNull)
    end

    specify "given a null object, returns the same null object" do
      null = ConvertableNull.get
      expect(Null(null)).to be(null)
    end

    specify "given anything in null_equivalents, returns a null object" do
      expect(Null("").class).to be(ConvertableNull)
    end

    specify "given false, raises an ArgumentError" do
      expect { Null(false) }.to raise_error(ArgumentError)
    end

    specify "given a non-empty string, raises an ArgumentError" do
      expect { Null("hello") }.to raise_error(ArgumentError)
    end

    it "generates null objects with trace info for file" do
      null, = Null(), __LINE__ # rubocop:disable Style/ParallelAssignment
      expect(null.__file__).to eq(__FILE__)
    end

    it "generates null objects with trace info for line" do
      null, line = Null(), __LINE__ # rubocop:disable Style/ParallelAssignment
      expect(null.__line__).to eq(line)
    end
  end
end
