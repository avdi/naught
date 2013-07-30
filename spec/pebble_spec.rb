require 'spec_helper'
require 'stringio'

describe 'pebble null object' do
  class Caller
    def call_method(thing)
      thing.info
    end
  end

  subject(:null) { null_class.new }
  let(:null_class) {
    output = test_output # getting local binding
    Naught.build do |b|
      b.pebble output
    end
  }

  let(:test_output) { StringIO.new }

  it 'prints the name of the method called' do
    expect(test_output).to receive(:puts).with(/^info\(\)/)
    null.info
  end

  it 'prints the arguments received' do
    expect(test_output).to receive(:puts).with(/^info\(\'foo\', 5, \:sym\)/)
    null.info("foo", 5, :sym)
  end

  it 'prints the name of the caller' do
    expect(test_output).to receive(:puts).with(/from call_method$/)
    Caller.new.call_method(null)
  end

  it 'returns self' do
    expect(null.info).to be(null)
  end
end
