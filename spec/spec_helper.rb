GEM_ROOT = File.expand_path("../../", __FILE__)
NIL_CONVERSION_METHODS = nil.methods.select{|method| method.to_s =~ /^to_\w+$/}
$:.unshift File.join(GEM_ROOT, "lib")

if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'naught'
Dir[File.join(GEM_ROOT, "spec", "support", "**/*.rb")].each { |f| require f }
