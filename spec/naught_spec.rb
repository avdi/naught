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
    it 'aliases .new to .get' do
      expect(null_class.get.class).to be(null_class)
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
    it 'aliases .instance to .get' do
      expect(null_class.get).to be null_class.instance
    end
    it 'permits arbitrary arguments to be passed to .get' do
      null_class.get(42, foo: "bar")
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
  describe 'using mimic with black_hole' do
    require 'logger'
    subject(:null) { mimic_class.new }
    let(:mimic_class) {
      Naught.build do |b|
        b.mimic Logger
        b.black_hole
      end
    }
  
    def self.it_behaves_like_a_black_hole_mimic
      it 'returns self from mimicked methods' do
        expect(null.info).to equal(null)
        expect(null.error).to equal(null)
        expect(null << "test").to equal(null)
      end
  
      it 'does not respond to methods not defined on the target class' do
        expect{null.foobar}.to raise_error(NoMethodError)
      end
    end
  
    it_behaves_like_a_black_hole_mimic
  
    describe '(reverse order)' do
      let(:mimic_class) {
        Naught.build do |b|
          b.black_hole
          b.mimic Logger
        end
      }
  
      it_behaves_like_a_black_hole_mimic
    end
  end
  describe 'null object impersonating another type' do
    class Point
      def x; 23; end
      def y; 42; end
    end
  
    subject(:null) { impersonation_class.new }
    let(:impersonation_class) {
      Naught.build do |b|
        b.impersonate Point
      end
    }
  
    it 'matches the impersonated type' do
      expect(Point).to be === null
    end
  
    it 'responds to methods from the impersonated type' do
      expect(null.x).to be_nil
      expect(null.y).to be_nil
    end
  
    it 'does not respond to unknown methods' do
      expect{null.foo}.to raise_error(NoMethodError)
    end
  end
  describe 'traceable null object' do
    subject(:trace_null) {
      null_object_and_line.first
    }
    let(:null_object_and_line) {
      obj = trace_null_class.new; line = __LINE__;
      [obj, line]
    }
    let(:instantiation_line) { null_object_and_line.last }
    let(:trace_null_class) {
      Naught.build do |b|
        b.traceable
      end
    }
    
    it 'remembers the file it was instantiated from' do
      expect(trace_null.__file__).to eq(__FILE__)    
    end
  
    it 'remembers the line it was instantiated from' do
      expect(trace_null.__line__).to eq(instantiation_line)
    end
    def make_null
      trace_null_class.get(caller: caller(1))
    end
    
    it 'can accept custom backtrace info' do
      obj = make_null; line = __LINE__
      expect(obj.__line__).to eq(line)
    end
  end
  describe 'customized null object' do
    subject(:custom_null) { custom_null_class.new }
    let(:custom_null_class) {
      Naught.build do |b|
        b.define_explicit_conversions
        def to_path
          "/dev/null"
        end
        def to_s
          "NOTHING TO SEE HERE"
        end
      end
    }
    
    it 'responds to custom-defined methods' do
      expect(custom_null.to_path).to eq("/dev/null")
    end
  
    it 'allows generated methods to be overridden' do
      expect(custom_null.to_s).to eq("NOTHING TO SEE HERE")
    end
  end
  TestNull = Naught.build
  
  describe 'a named null object class' do
    it 'has named ancestor modules' do
      expect(TestNull.ancestors[0..2].map(&:name)).to eq([
          'Naught::TestNull', 
          'Naught::TestNull::Customizations', 
          'Naught::TestNull::GeneratedMethods'
        ])
    end
  end
end
