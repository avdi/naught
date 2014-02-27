require 'spec_helper'

describe 'null object impersonating another type' do
  class Point
    def x
      23
    end

    def y
      42
    end
  end

  subject(:null) { impersonation_class.new }
  let(:impersonation_class) do
    Naught.build do |b|
      b.impersonate Point
    end
  end

  it 'matches the impersonated type' do
    expect(null).to be_a Point
  end

  it 'responds to methods from the impersonated type' do
    expect(null.x).to be_nil
    expect(null.y).to be_nil
  end

  it 'does not respond to unknown methods' do
    expect { null.foo }.to raise_error(NoMethodError)
  end
end
