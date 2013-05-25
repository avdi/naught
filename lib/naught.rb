
require "naught/version"

module Naught
  class NullObject < BasicObject
    def method_missing(*)
      # NOOP
    end
  end
end
