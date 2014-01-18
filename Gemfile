source 'https://rubygems.org'

# Specify your gem's dependencies in naught.gemspec
gemspec

gem 'rake'

group :development do
  platforms :ruby_19, :ruby_20, :ruby_21 do
    gem 'guard'
    gem 'guard-bundler'
    gem 'guard-rspec'
  end
  gem 'pry'
  gem 'pry-rescue'
end

group :test do
  gem 'coveralls', :require => false
  gem 'json', :platforms => [:jruby, :rbx, :ruby_18, :ruby_19]
  gem 'libnotify'
  gem 'mime-types', '~> 1.25', :platforms => [:jruby, :ruby_18]
  gem 'rspec', '>= 2.14'
  gem 'rubocop', '>= 0.16', :platforms => [:ruby_19, :ruby_20, :ruby_21]
end

platforms :rbx do
  gem 'racc'
  gem 'rubinius-coverage', '~> 2.0'
  gem 'rubysl', '~> 2.0'
end
