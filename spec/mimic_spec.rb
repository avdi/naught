require "spec_helper"
require "logger"

module MimicSpecFixtures
  class User
    attr_reader :login
  end

  module Authorizable
    def authorized_for?(_)
    end
  end

  class LibraryPatron < User
    include Authorizable

    attr_reader :name

    def member?
    end

    def notify_of_overdue_books(_)
    end
  end

  class BasicWidget < BasicObject
    def widget_method
    end
  end
end

RSpec.describe Naught do
  describe "null object mimicking a class" do
    subject(:null) { mimic_class.new }

    let(:mimic_class) do
      described_class.build do |b|
        b.mimic MimicSpecFixtures::LibraryPatron
      end
    end

    it "responds to member? method" do
      expect(null.member?).to be_nil
    end

    it "responds to name method" do
      expect(null.name).to be_nil
    end

    it "responds to notify_of_overdue_books method" do
      expect(null.notify_of_overdue_books(["The Grapes of Wrath"])).to be_nil
    end

    it "does not respond to methods not defined on the target class" do
      expect { null.foobar }.to raise_error(NoMethodError)
    end

    it "reports it responds to member?" do
      expect(null).to respond_to(:member?)
    end

    it "reports it responds to name" do
      expect(null).to respond_to(:name)
    end

    it "reports it responds to notify_of_overdue_books" do
      expect(null).to respond_to(:notify_of_overdue_books)
    end

    it "reports it does not respond to foobar" do
      expect(null).not_to respond_to(:foobar)
    end

    it "has an informative inspect string" do
      expect(null.inspect).to eq("<null:MimicSpecFixtures::LibraryPatron>")
    end

    it "does not mimic object_id from Object" do
      expect(null.object_id).not_to be_nil
    end

    it "does not mimic hash from Object" do
      expect(null.hash).not_to be_nil
    end

    it "includes inherited method authorized_for?" do
      expect(null.authorized_for?("something")).to be_nil
    end

    it "includes inherited method login" do
      expect(null.login).to be_nil
    end

    describe "with include_super: false" do
      let(:mimic_class) do
        described_class.build do |b|
          b.mimic MimicSpecFixtures::LibraryPatron, include_super: false
        end
      end

      it "excludes inherited method authorized_for?" do
        expect(null).not_to respond_to(:authorized_for?)
      end

      it "excludes inherited method login" do
        expect(null).not_to respond_to(:login)
      end
    end

    describe "with an instance as example" do
      let(:mimic_class) do
        milton = MimicSpecFixtures::LibraryPatron.new
        def milton.stapler
        end
        described_class.build do |b|
          b.mimic example: milton
        end
      end

      it "responds to method defined only on the example instance" do
        expect(null).to respond_to(:stapler)
      end

      it "responds to method defined on the class of the instance" do
        expect(null).to respond_to(:member?)
      end
    end
  end

  describe "null object mimicking a BasicObject subclass" do
    subject(:null) { mimic_class.new }

    let(:mimic_class) do
      described_class.build do |b|
        b.mimic MimicSpecFixtures::BasicWidget
      end
    end

    it "uses BasicObject as the base class and responds to mimicked methods" do
      expect(null.widget_method).to be_nil
    end
  end

  describe "using mimic with black_hole" do
    subject(:null) { mimic_class.new }

    let(:mimic_class) do
      described_class.build do |b|
        b.mimic Logger
        b.black_hole
      end
    end

    shared_examples_for "a black hole mimic" do
      it "returns self from info method" do
        expect(null.info).to equal(null)
      end

      it "returns self from error method" do
        expect(null.error).to equal(null)
      end

      it "returns self from << method" do
        expect(null << "test").to equal(null)
      end

      it "does not respond to methods not defined on the target class" do
        expect { null.foobar }.to raise_error(NoMethodError)
      end
    end

    it_behaves_like "a black hole mimic"

    describe "(reverse order)" do
      let(:mimic_class) do
        described_class.build do |b|
          b.black_hole
          b.mimic Logger
        end
      end

      it_behaves_like "a black hole mimic"
    end
  end
end
