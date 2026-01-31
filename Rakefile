require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

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

task default: %i[test lint]
