require "naught/version"
require 'naught/null_class_builder'
require 'naught/null_class_builder/commands'

class TestTest
  def build()
    ["a","b","c"].each {|s|
      p s unless s == "test"
     }
  end
end
