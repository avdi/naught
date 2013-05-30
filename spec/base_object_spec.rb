require 'spec_helper'

describe 'null object base class could be configured' do

  subject(:null) { configured_base_null_class.new }

  let(:configured_base_null_class) do
    Naught.build do |b|
      b.base_class Object
    end
  end

  it 'respond to base class methods' do
    expect(null.methods).to be_a_kind_of(Array)
  end

  it 'respond to unknown methods' do
    expect(null.foo).to be_nil
  end

  describe 'singleton null object' do
    subject(:null_instance) { configured_base_singleton_null_class.instance }

    let(:configured_base_singleton_null_class) do
      Naught.build do |b|
        b.singleton
        b.base_class Object
      end
    end

    it 'can be cloned' do
      expect(null_instance.clone).to be_nil
    end

    it 'can be duplicated' do
      expect(null_instance.dup).to be_nil
    end
  end
end
