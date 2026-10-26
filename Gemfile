source "https://rubygems.org"

gemspec

group :development do
  # Duel requires Ruby 3.4 or later
  gem "duel", ">= 0.1.1" if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4")
  gem "stackprof", platforms: :mri
end

group :test do
  gem "logger"
  gem "minitest", ">= 6"
  gem "minitest-mock"
  gem "minitest-strict"
  gem "rake"
  gem "rdoc"
  gem "rubocop-minitest"
  gem "rubocop-performance"
  gem "simplecov", ">= 1"
  gem "standard"
  gem "standard-performance"
end

group :docs do
  gem "irb"
  gem "redcarpet", platforms: :mri
  gem "yard"
  gem "yardstick"
end

group :typecheck do
  gem "steep", platforms: :mri
end
