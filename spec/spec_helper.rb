GEM_ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(GEM_ROOT, 'lib')

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'naught'
Dir[File.join(GEM_ROOT, 'spec', 'support', '**/*.rb')].each { |f| require f }
