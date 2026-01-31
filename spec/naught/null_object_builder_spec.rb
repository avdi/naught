require "spec_helper"

module Naught
  class NullClassBuilder
    module Commands
      class TestCommand
        def initialize(_builder, *_args)
        end

        def call
        end
      end
    end
  end

  RSpec.describe NullClassBuilder do
    subject(:builder) { described_class.new }

    it "responds to commands defined in NullObjectBuilder::Commands" do
      expect(builder).to respond_to(:test_command)
    end

    describe "command invocation" do
      let(:test_command) { instance_double(NullClassBuilder::Commands::TestCommand) }

      before do
        allow(NullClassBuilder::Commands::TestCommand).to receive(:new)
          .with(builder, "foo", 42)
          .and_return(test_command)
        allow(test_command).to receive(:call).and_return("COMMAND RESULT")
      end

      it "returns the result of the command call" do
        expect(builder.test_command("foo", 42)).to eq("COMMAND RESULT")
      end

      it "instantiates the command with builder and arguments" do
        builder.test_command("foo", 42)
        expect(NullClassBuilder::Commands::TestCommand).to have_received(:new).with(builder, "foo", 42)
      end

      it "calls the command" do
        builder.test_command("foo", 42)
        expect(test_command).to have_received(:call)
      end
    end

    it "does not respond to nonexistent methods" do
      expect(builder).not_to respond_to(:nonexistant_method)
    end

    it "raises NoMethodError for nonexistent methods" do
      expect { builder.nonexistent_method }.to raise_error(NoMethodError)
    end

    it "handles method names that would create invalid constant names" do
      expect(builder).not_to respond_to(:"123invalid")
    end
  end
end
