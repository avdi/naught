require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    warn "RuboCop is disabled"
  end
end

begin
  require "standard/rake"
rescue LoadError
  task :standard do
    warn "Standard is disabled"
  end
  task "standard:fix" do
    warn "Standard is disabled"
  end
end

desc "Run all linters (RuboCop and Standard)"
task lint: %i[rubocop standard]

desc "Fix all auto-correctable lint issues"
task "lint:fix": %i[rubocop:autocorrect_all standard:fix]

task default: %i[spec lint]
