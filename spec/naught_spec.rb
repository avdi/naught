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
  describe 'implicit conversions' do
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
  end
end
