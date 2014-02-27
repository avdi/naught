require 'spec_helper'

describe 'implicitly convertable null object' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build do |b|
      b.define_implicit_conversions
    end
  end

  context 'to_ary' do
    it 'returns empty array' do
      expect(null.to_ary).to eq([])
    end

    it 'makes splats possible' do
      a, b = null
      expect(a).to be_nil
      expect(b).to be_nil
    end
  end

  context 'to_str' do
    it 'returns empty string for to_str' do
      expect(null.to_str).to eq('')
    end

    it 'makes instance_eval possible' do
      expect(instance_eval(null)).to be_nil
    end
  end
end
