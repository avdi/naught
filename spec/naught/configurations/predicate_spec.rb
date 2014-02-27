require 'spec_helper'

describe 'a null object with predicates_return(false)' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build do |config|
      config.predicates_return false
    end
  end

  it 'responds to predicate-style methods with false' do
    expect(null.too_much_coffee?).to eq(false)
  end

  it 'responds to other methods with nil' do
    expect(null.foobar).to eq(nil)
  end
end
