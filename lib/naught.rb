
require "naught/version"

module Naught
  class NullObject < BasicObject
    def method_missing(*)
      # NOOP
    end
    def respond_to?(*)
      true
    end
  end
end
