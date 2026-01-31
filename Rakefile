require "bundler/gem_tasks"
# Override release task to skip gem push (handled by GitHub Actions with attestations)
Rake::Task["release"].clear
desc "Build gem and create tag (gem push handled by CI)"
task release: %w[build release:guard_clean release:source_control_push]

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

begin
  require "yaml"
  require "yard/rake/yardoc_task"
  require "yardstick/rake/verify"

  desc "Generate YARD documentation"
  YARD::Rake::YardocTask.new(:yard) do |t|
    t.files = ["lib/**/*.rb"]
    t.options = ["--no-private"]
  end

  desc "Verify YARD documentation coverage"
  options = YAML.load_file(".yardstick.yml", permitted_classes: [Symbol])
  Yardstick::Rake::Verify.new(:yardstick, options)
  task yardstick: :yard
rescue LoadError
  task :yard do
    warn "YARD is disabled"
  end
  task :yardstick do
    warn "Yardstick is disabled"
  end
end

begin
  require "steep"

  desc "Type check with Steep"
  task :steep do
    # Use --log-level=fatal to suppress internal Steep worker debug messages
    sh "bundle exec steep check --log-level=fatal"
  end
rescue LoadError
  task :steep do
    warn "Steep is disabled"
  end
end

desc "Run all linters (RuboCop and Standard)"
task lint: %i[rubocop standard]

desc "Fix all auto-correctable lint issues"
task "lint:fix": %i[rubocop:autocorrect_all standard:fix]

task default: %i[test lint yardstick steep]
