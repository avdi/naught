lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "naught/version"

Gem::Specification.new do |spec|
  spec.name = "naught"
  spec.version = Naught::VERSION
  spec.authors = ["Avdi Grimm"]
  spec.email = ["avdi@avdi.org"]
  spec.description = "Naught is a toolkit for building Null Objects"
  spec.summary = spec.description
  spec.homepage = "https://github.com/avdi/naught"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.markdown", "Changelog.md"]
  spec.require_paths = ["lib"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/avdi/naught"
  spec.metadata["changelog_uri"] = "https://github.com/avdi/naught/blob/master/Changelog.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 12.0"
end
