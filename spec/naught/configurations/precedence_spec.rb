require 'spec_helper'

describe 'configuration precedence of a null object' do
  subject(:null) { null_class.new }

  context 'black_hole, predicates_return' do
    shared_examples 'behavior' do
      it 'responds to predicate-style methods with false' do
        expect(null.too_much_coffee?).to eq(false)
      end

      it 'responds to other methods with self' do
        expect(null.foobar).to be(null)
      end
    end

    context 'black_hole first' do
      let(:null_class) do
        Naught.build do |config|
          config.black_hole
          config.predicates_return false
        end
      end

      include_examples 'behavior'
    end

    context 'predicates_return first' do
      let(:null_class) do
        Naught.build do |config|
          config.predicates_return false
          config.black_hole
        end
      end

      include_examples 'behavior'
    end
  end

  context 'black_hole, mimic' do
    shared_examples 'behavior' do
      it 'returns self from mimicked methods' do
        expect(null.info).to equal(null)
        expect(null.error).to equal(null)
        expect(null << 'test').to equal(null)
      end

      it 'does not respond to methods not defined on the target class' do
        expect { null.foobar }.to raise_error(NoMethodError)
      end
    end

    describe 'black_hole first' do
      let(:null_class) do
        Naught.build do |b|
          b.black_hole
          b.mimic Logger
        end
      end

      include_examples 'behavior'
    end

    describe 'mimic first' do
      let(:null_class) do
        Naught.build do |b|
          b.mimic Logger
          b.black_hole
        end
      end

      include_examples 'behavior'
    end
  end

  context 'mimic, predicates_return' do
    class Coffee
      def black?
        true
      end

      def origin
        'Ethiopia'
      end
    end

    let(:null_class) do
      Naught.build do |config|
        config.mimic Coffee
        config.predicates_return false
      end
    end

    it 'responds to predicate-style methods with false' do
      expect(null.black?).to eq(false)
    end

    it 'responds to other methods with nil' do
      expect(null.origin).to be(nil)
    end

    it 'does not respond to undefined methods' do
      expect(null).not_to respond_to(:leaf_variety)
      expect { null.leaf_variety }.to raise_error(NoMethodError)
    end
  end

  describe 'customs methods, define_explicit_conversions' do
    let(:null_class) do
      Naught.build do |b|
        b.define_explicit_conversions
        def to_s
          'NOTHING TO SEE HERE'
        end
      end
    end

    it 'allows generated methods to be overridden' do
      expect(null.to_s).to eq('NOTHING TO SEE HERE')
    end
  end
end
