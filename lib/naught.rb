
require "naught/version"

module Naught
  def self.build
    Class.new(BasicObject) do
      def method_missing(*)
        # NOOP
      end
      def respond_to?(*)
        true
      end
    end
  end
end
