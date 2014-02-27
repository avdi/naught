require 'spec_helper'

describe 'null object with a custom base class' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build do |b|
      b.base_class = Object
    end
  end

  it 'responds to base class methods' do
    expect(null.methods).to be_an Array
  end

  it 'responds to unknown methods' do
    expect(null.foo).to be_nil
  end

  it 'exposes the default base class choice, for the curious' do
    default_base_class = :not_set
    Naught.build do |b|
      default_base_class = b.base_class
    end
    expect(default_base_class).to eq(Naught::BasicObject)
  end
end
