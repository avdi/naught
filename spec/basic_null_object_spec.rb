require "spec_helper"

RSpec.describe Naught do
  describe "basic null object" do
    subject(:null) { null_class.new }

    let(:null_class) { described_class.build }

    it "responds to arbitrary messages and returns nil" do
      expect(null.info).to be_nil
    end

    it "responds to arbitrary unknown messages and returns nil" do
      expect(null.foobaz).to be_nil
    end

    it "responds to to_s and returns nil" do
      expect(null.to_s).to be_nil
    end

    it "accepts any arguments for any messages" do
      expect { null.foobaz(1, 2, 3) }.not_to raise_error
    end

    it "reports that it responds to info" do
      expect(null).to respond_to(:info)
    end

    it "reports that it responds to foobaz" do
      expect(null).to respond_to(:foobaz)
    end

    it "reports that it responds to to_s" do
      expect(null).to respond_to(:to_s)
    end

    it "can be inspected" do
      expect(null.inspect).to eq("<null>")
    end

    it "knows its own class" do
      expect(null.class).to eq(null_class)
    end

    it "aliases .new to .get" do
      expect(null_class.get.class).to be(null_class)
    end
  end
end
