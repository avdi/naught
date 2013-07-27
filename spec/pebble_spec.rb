require 'spec_helper'

describe 'pebble null object' do
  class Caller
    def call_method(thing)
      thing.info
    end
  end

  subject(:null) { null_class.new }
  let(:null_class) {
    Naught.build do |b|
      b.pebble
    end
  }

  before do
    allow(Kernel).to receive(:p)
  end

  it 'prints the name of the method called' do
    expect(Kernel).to receive(:p).with(/^info\(\)/)
    null.info
  end

  it 'prints the arguments received' do
    expect(Kernel).to receive(:p).with(/^info\(\'foo\', 5, \:sym\)/)
    null.info("foo", 5, :sym)
  end

  it 'prints the name of the caller' do
    expect(Kernel).to receive(:p).with(/from call_method$/)
    Caller.new.call_method(null)
  end

  it 'returns self' do
    expect(null.info).to be(null)
  end
end