require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    $stderr.puts 'Rubocop is disabled'
  end
end

task :default => [:spec, :rubocop]

task :mutant => :spec do
  require 'mutant'

  ignores = [
    # Mutation with infinite runtime
    'Naught::NullClassBuilder::Commands::Pebble#call'
  ]

  arguments = []
  arguments << '--include' << 'lib'
  arguments << '--require' << 'naught'
  arguments << '--use'     << 'rspec'
  arguments << '--score'   << '87.02'
  arguments << 'Naught*'
  ignores.each do |ignore|
    arguments << '--ignore-subject' << ignore
  end
  fail unless Mutant::CLI.run(arguments)
end
