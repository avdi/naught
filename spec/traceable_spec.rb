require 'spec_helper'

describe 'traceable null object' do
  subject(:trace_null) do
    null_object_and_line.first
  end
  let(:null_object_and_line) do
    obj, line = trace_null_class.new, __LINE__
    [obj, line]
  end
  let(:instantiation_line) { null_object_and_line.last }
  let(:trace_null_class) do
    Naught.build do |b|
      b.traceable
    end
  end

  it 'remembers the file it was instantiated from' do
    expect(trace_null.__file__).to eq(__FILE__)
  end

  it 'remembers the line it was instantiated from' do
    expect(trace_null.__line__).to eq(instantiation_line)
  end

  def make_null
    trace_null_class.get(:caller => caller(1))
  end

  it 'can accept custom backtrace info' do
    obj, line = make_null, __LINE__
    expect(obj.__line__).to eq(line)
  end
end
