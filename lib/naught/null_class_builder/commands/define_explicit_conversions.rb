
module Naught
  class NullClassBuilder
    module Commands
      class DefineExplicitConversions
        def initialize(builder)
          @builder = builder
        end

        def call
          defer do |subject|
            subject.module_eval do
              def to_s; ""; end
              def to_i; 0; end
              def to_f; 0.0; end
              def to_c; 0.to_c; end
              def to_r; 0.to_r; end
              def to_a; []; end
              def to_h; {}; end
            end
          end
        end

        def defer(&block)
          @builder.defer(&block)
        end
      end
    end
  end
end
