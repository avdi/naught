require "spec_helper"

RSpec.describe Naught do
  describe "explicitly convertable null object" do
    subject(:null) { null_class.new }

    let(:null_class) do
      described_class.build(&:define_explicit_conversions)
    end

    it "converts to empty string" do
      expect(null.to_s).to eq("")
    end

    it "converts to empty array" do
      expect(null.to_a).to eq([])
    end

    it "converts to zero integer" do
      expect(null.to_i).to eq(0)
    end

    it "converts to zero float" do
      expect(null.to_f).to eq(0.0)
    end

    it "converts to empty hash" do
      expect(null.to_h).to eq({})
    end
  end
end
