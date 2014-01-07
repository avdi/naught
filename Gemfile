source 'https://rubygems.org'

# Specify your gem's dependencies in naught.gemspec
gemspec

gem 'rake'

group :development do
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'pry'
  gem 'pry-rescue'
end

group :test do
  gem 'coveralls', :require => false
  gem 'libnotify'
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rspec', '~> 2.14'
end

platforms :rbx do
  gem 'json'
  gem 'rubinius-coverage', '~> 2.0'
  gem 'rubysl', '~> 2.0'
end
