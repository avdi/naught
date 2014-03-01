require 'spec_helper'

describe 'implicitly convertable null object' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build do |b|
      b.define_implicit_conversions
    end
  end

  describe 'array implicit conversions' do
    it 'returns empty array for to_ary' do
      expect(null.to_ary).to eq([])
    end

    it 'makes splats possible' do
      a, b = null
      expect(a).to be_nil
      expect(b).to be_nil
    end
  end

  describe 'string implicit conversions' do
    it 'returns empty string for to_str' do
      expect(null.to_str).to eq('')
    end

    it 'makes instance_eval possible' do
      expect(instance_eval(null)).to be_nil
    end
  end
end
