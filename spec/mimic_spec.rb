require 'spec_helper'
require 'logger'

describe 'null object mimicking a class' do
  class User
    def login
      'bob'
    end
  end

  module Authorizable
    def authorized_for?(object)
      true
    end
  end

  class LibraryPatron < User
    include Authorizable

    def member?
      true
    end

    def name
      'Bob'
    end

    def notify_of_overdue_books(titles)
      puts 'Notifying...'
    end
  end

  subject(:null) { mimic_class.new }
  let(:mimic_class) do
    Naught.build do |b|
      b.mimic LibraryPatron
    end
  end
  it 'responds to all methods defined on the target class' do
    expect(null.member?).to be_nil
    expect(null.name).to be_nil
    expect(null.notify_of_overdue_books(['The Grapes of Wrath'])).to be_nil
  end

  it 'does not respond to methods not defined on the target class' do
    expect { null.foobar }.to raise_error(NoMethodError)
  end

  it 'reports which messages it does and does not respond to' do
    expect(null).to respond_to(:member?)
    expect(null).to respond_to(:name)
    expect(null).to respond_to(:notify_of_overdue_books)
    expect(null).not_to respond_to(:foobar)
  end
  it 'has an informative inspect string' do
    expect(null.inspect).to eq('<null:LibraryPatron>')
  end

  it 'excludes Object methods from being mimicked' do
    expect(null.object_id).not_to be_nil
    expect(null.hash).not_to be_nil
  end

  it 'includes inherited methods' do
    expect(null.authorized_for?('something')).to be_nil
    expect(null.login).to be_nil
  end

  describe 'with include_super: false' do
    let(:mimic_class) do
      Naught.build do |b|
        b.mimic LibraryPatron, :include_super => false
      end
    end

    it 'excludes inherited methods' do
      expect(null).to_not respond_to(:authorized_for?)
      expect(null).to_not respond_to(:login)
    end
  end
end

describe 'using mimic with black_hole' do
  subject(:null) { mimic_class.new }
  let(:mimic_class) do
    Naught.build do |b|
      b.mimic Logger
      b.black_hole
    end
  end

  def self.it_behaves_like_a_black_hole_mimic
    it 'returns self from mimicked methods' do
      expect(null.info).to equal(null)
      expect(null.error).to equal(null)
      expect(null << 'test').to equal(null)
    end

    it 'does not respond to methods not defined on the target class' do
      expect { null.foobar }.to raise_error(NoMethodError)
    end
  end

  it_behaves_like_a_black_hole_mimic

  describe '(reverse order)' do
    let(:mimic_class) do
      Naught.build do |b|
        b.black_hole
        b.mimic Logger
      end
    end

    it_behaves_like_a_black_hole_mimic
  end

end
