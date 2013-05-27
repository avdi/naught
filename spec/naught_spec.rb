require 'spec_helper'
require 'naught'

module Naught
  describe 'basic null object' do
    subject(:null) { null_class.new }
    let(:null_class) {
      Naught.build
    }
    it 'responds to arbitrary messages and returns nil' do
      expect(null.info).to be_nil
      expect(null.foobaz).to be_nil
      expect(null.to_s).to be_nil
    end
    
    it 'accepts any arguments for any messages' do
      null.foobaz(1,2,3)
    end
    it 'reports that it responds to any message' do
      expect(null).to respond_to(:info)
      expect(null).to respond_to(:foobaz)
      expect(null).to respond_to(:to_s)
    end
    it 'can be inspected' do
      expect(null.inspect).to eq("<null>")
    end
    it 'knows its own class' do
      expect(null.class).to eq(null_class)
    end
  end
  describe 'explicitly convertable null object' do
    subject(:null) { null_class.new }
    let(:null_class) { 
      Naught.build do |b|
        b.define_explicit_conversions
      end
    }
  
    it "defines common explicit conversions to return zero values" do
      expect(null.to_s).to eq("")
      expect(null.to_a).to eq([])
      expect(null.to_i).to eq(0)
      expect(null.to_f).to eq(0.0)
      expect(null.to_c).to eq(Complex(0))
      expect(null.to_r).to eq(Rational(0))
      expect(null.to_h).to eq({})
    end
  end
  describe 'implicitly convertable null object' do
    subject(:null) { null_class.new }
    let(:null_class) {
      Naught.build do |b|
        b.define_implicit_conversions
      end
    }
    it 'implicitly splats the same way an empty array does' do
      a, b = null
      expect(a).to be_nil
      expect(b).to be_nil
    end
    it 'is implicitly convertable to String' do
      expect(eval(null)).to be_nil
    end
    it 'implicitly converts to an empty array' do
      expect(null.to_ary).to eq([])
    end
    it 'implicitly converts to an empty string' do
      expect(null.to_str).to eq("")
    end
  
  end
  describe 'singleton null object' do
    subject(:null_class) { 
      Naught.build do |b|
        b.singleton
      end
    }
  
    it 'does not respond to .new' do
      expect{ null_class.new }.to raise_error
    end
  
    it 'has only one instance' do
      null1 = null_class.instance
      null2 = null_class.instance
      expect(null1).to be(null2)
    end
  
    it 'can be cloned' do
      null = null_class.instance
      expect(null.clone).to be_nil
    end
    
    it 'can be duplicated' do
      null = null_class.instance
      expect(null.dup).to be_nil
    end
  end
  describe 'black hole null object' do
    subject(:null) { null_class.new }
    let(:null_class) {
      Naught.build do |b|
        b.black_hole
      end
    }
    
    it 'returns self from arbitray method calls' do
      expect(null.info).to be(null)
      expect(null.foobaz).to be(null)
      expect(null << "bar").to be(null)
    end
  end
  describe 'null object mimicking a class' do
    class User
      def login
        "bob"
      end
    end
  
    module Authorizable
      def authorized_for?(object)
        true
      end
    end
   
    class LibraryPatron < User
      include Authorizable
  
      def member?; true; end
      def name; "Bob"; end
      def notify_of_overdue_books(titles)
        puts "Notifying Bob his books are overdue..."
      end
    end
      
    subject(:null) { mimic_class.new }
    let(:mimic_class) { 
      Naught.build do |b|
        b.mimic LibraryPatron
      end
    }
    it 'responds to all methods defined on the target class' do
      expect(null.member?).to be_nil
      expect(null.name).to be_nil
      expect(null.notify_of_overdue_books(['The Grapes of Wrath'])).to be_nil
    end
      
    it 'does not respond to methods not defined on the target class' do
      expect{null.foobar}.to raise_error(NoMethodError)
    end
    
    it 'reports which messages it does and does not respond to' do
      expect(null).to respond_to(:member?)
      expect(null).to respond_to(:name)
      expect(null).to respond_to(:notify_of_overdue_books)
      expect(null).not_to respond_to(:foobar)
    end
    it 'has an informative inspect string' do
      expect(null.inspect).to eq("<null:Naught::LibraryPatron>")
    end
    
    it 'excludes Object methods from being mimicked' do
      expect(null.object_id).not_to be_nil
      expect(null.hash).not_to be_nil
    end
  
    it 'includes inherited methods' do
      expect(null.authorized_for?('something')).to be_nil
      expect(null.login).to be_nil
    end
  
    describe 'with include_super: false' do
      let(:mimic_class) { 
        Naught.build do |b|
          b.mimic LibraryPatron, include_super: false
        end
      }
      
      it 'excludes inherited methods' do
        expect(null).to_not respond_to(:authorized_for?)
        expect(null).to_not respond_to(:login)
      end
    end
  end
end
