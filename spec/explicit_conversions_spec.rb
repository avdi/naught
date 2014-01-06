require 'spec_helper.rb'

describe 'explicitly convertable null object' do
  let(:null_class) {
    Naught.build do |b|
      b.define_explicit_conversions
    end
  }
  subject(:null) { null_class.new }

  NIL_CONVERSION_METHODS.each do |conversion_method|
    it "##{conversion_method} responds like nil" do
      # We need to call inspect to compare Enumerators
      expect(null.__send__(conversion_method).inspect).to eq(nil.send(conversion_method).inspect)
    end
  end
end
