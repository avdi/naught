require 'spec_helper'

describe 'black hole null object' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build(&:black_hole)
  end

  it 'returns self from arbitray method calls' do
    expect(null.info).to be(null)
    expect(null.foobaz).to be(null)
    expect(null << 'bar').to be(null)
  end

  it 'can be a hash value when serialized as yaml' do
    hash_with_null_object_value  = {:null => null}
    expect(hash_with_null_object_value.to_yaml).to eq("---\n:null: !ruby/object {}\n")
  end
end
