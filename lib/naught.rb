require "naught/version"

module Naught
  def self.build
    klass = Class.new(BasicObject) do
      def method_missing(*)
        # NOOP
      end
      def respond_to?(*)
        true
      end
    end
    builder = NullClassBuilder.new(klass)
    yield(builder) if block_given?
    klass
  end
  class NullClassBuilder
    def initialize(subject)
      @subject = subject
    end
  
    def define_explicit_conversions
      @subject.module_eval do
        def to_s; ""; end
        def to_i; 0; end
        def to_f; 0.0; end
        def to_c; 0.to_c; end
        def to_r; 0.to_r; end
        def to_a; []; end
        def to_h; {}; end
      end
    end
  
    def define_implicit_conversions
      @subject.module_eval do
        def to_ary; []; end
        def to_str; ''; end
      end
    end
  end
end
