require 'spec_helper.rb'

describe 'explicitly convertable null object' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build do |b|
      b.define_explicit_conversions
    end
  end

  it 'returns empty string for to_s' do
    expect(null.to_s).to eq('')
  end

  it 'returns empty array for to_a' do
    expect(null.to_a).to eq([])
  end

  it 'returns 0 for to_i' do
    expect(null.to_i).to eq(0)
  end

  it 'returns 0.0 for to_f' do
    expect(null.to_f).to eq(0.0)
  end

  if RUBY_VERSION >= '1.9'
    it 'returns Complex(0) for to_c' do
      expect(null.to_c).to eq(Complex(0))
    end

    it 'returns Rational(0) for to_r' do
      expect(null.to_r).to eq(Rational(0))
    end
  end

  if RUBY_VERSION >= '2.0'
    it 'returns empty hash for to_h' do
      expect(null.to_h).to eq({})
    end
  end
end
