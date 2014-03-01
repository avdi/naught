require 'spec_helper'

describe 'null object with custom methods' do
  subject(:null) { null_class.new }
  let(:null_class) do
    Naught.build do |b|
      def to_path
        '/dev/null'
      end
    end
  end

  it 'responds to defined methods ' do
    expect(null.to_path).to eq('/dev/null')
  end
end
