GEM_ROOT = File.expand_path("..", __dir__)
$LOAD_PATH.unshift File.join(GEM_ROOT, "lib")

require "simplecov"

SimpleCov.start do
  skip "/test/"
  if RUBY_ENGINE != "jruby"
    enable_coverage :branch
    minimum_coverage line: 100, branch: 100
  else
    minimum_coverage line: 99.5
  end
end

require "minitest/autorun"
require "minitest/strict"
require "naught"
Dir[File.join(GEM_ROOT, "test", "support", "**/*.rb")].each { |f| require f }
