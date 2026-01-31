GEM_ROOT = File.expand_path('..', __dir__)
$LOAD_PATH.unshift File.join(GEM_ROOT, 'lib')

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage(100)
end

require 'naught'
Dir[File.join(GEM_ROOT, 'spec', 'support', '**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  # Allow monkey patching for simpler spec syntax
  # config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
