require 'spec_helper'

describe 'black hole null object' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build do |b|
      b.black_hole
    end
  end

  it 'returns self from arbitray method calls' do
    expect(null.info).to be(null)
    expect(null.foobaz).to be(null)
    expect(null << 'bar').to be(null)
  end

  it 'supports chaining of methodcalls' do
    expect(null.foo).to be(null)
    expect(null.foo.bar.baz).to be(null)
    expect(null << "hello" << "world").to be(null)
  end
end
