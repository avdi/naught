require "spec_helper"

RSpec.describe Naught do
  describe "black hole null object" do
    subject(:null) { null_class.new }

    let(:null_class) do
      described_class.build(&:black_hole)
    end

    it "returns self from info method call" do
      expect(null.info).to be(null)
    end

    it "returns self from foobaz method call" do
      expect(null.foobaz).to be(null)
    end

    it "returns self from << method call" do
      expect(null << "bar").to be(null)
    end
  end
end
