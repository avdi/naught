require "spec_helper"
require "stringio"

module PebbleSpecFixtures
  class Caller
    def call_method(thing)
      thing.info
    end

    def call_method_inside_block(thing)
      2.times.each { thing.info }
    end

    def call_method_inside_nested_block(thing)
      2.times.each { 2.times.each { thing.info } }
    end
  end
end

RSpec.describe Naught do
  describe "pebble null object" do
    subject(:null) { null_class.new }

    let(:null_class) do
      output = test_output # getting local binding
      described_class.build do |b|
        b.pebble output
      end
    end

    let(:test_output) { StringIO.new }

    it "prints the name of the method called" do
      allow(test_output).to receive(:puts)
      null.info
      expect(test_output).to have_received(:puts).with(/^info\(\)/)
    end

    it "prints the arguments received" do
      allow(test_output).to receive(:puts)
      null.info("foo", 5, :sym)
      expect(test_output).to have_received(:puts).with(/^info\('foo', 5, :sym\)/)
    end

    it "prints the name of the caller" do
      allow(test_output).to receive(:puts)
      PebbleSpecFixtures::Caller.new.call_method(null)
      expect(test_output).to have_received(:puts).with(/call_method$/)
    end

    it "returns self" do
      allow(test_output).to receive(:puts)
      expect(null.info).to be(null)
    end

    context "when is called from a block", skip: jruby? do
      it "prints the indication of a block" do
        allow(test_output).to receive(:puts)
        PebbleSpecFixtures::Caller.new.call_method_inside_block(null)
        expect(test_output).to have_received(:puts).twice.with(/block/)
      end

      it "prints the name of the method that has the block" do
        allow(test_output).to receive(:puts)
        PebbleSpecFixtures::Caller.new.call_method_inside_block(null)
        expect(test_output).to have_received(:puts).twice.with(/call_method_inside_block$/)
      end
    end

    context "when is called from many levels blocks", skip: jruby? do
      it "prints the indication of blocks and its levels" do
        allow(test_output).to receive(:puts)
        PebbleSpecFixtures::Caller.new.call_method_inside_nested_block(null)
        expect(test_output).to have_received(:puts).exactly(4).times.with(/block \(2 levels\)/)
      end

      it "prints the name of the method that has the block" do
        allow(test_output).to receive(:puts)
        PebbleSpecFixtures::Caller.new.call_method_inside_nested_block(null)
        expect(test_output).to have_received(:puts).exactly(4).times.with(/call_method_inside_nested_block$/)
      end
    end
  end
end
