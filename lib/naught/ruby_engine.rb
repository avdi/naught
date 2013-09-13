module RubyEngine

  def self.engine_mappings
    {
      'ruby' => MRI,
      'rbx' => RBX,
      'jruby' => JRuby,
    }
  end

  module_function

  def engine
    engine_mappings[RUBY_ENGINE]
  end

  def backtrace_initialization_offset
    engine.backtrace_initialization_offset
  end

  module MRI
    def self.backtrace_initialization_offset
      4
    end
  end

  module RBX
    def self.backtrace_initialization_offset
      3
    end
  end

  module JRuby
    def self.backtrace_initialization_offset
      3
    end
  end
end
