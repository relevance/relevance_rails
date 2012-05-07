require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new
task :default => :spec

desc 'Run the acceptance specs'
task :acceptance do
  ENV["ACCEPTANCE"] = "true"
  Rake::Task[:spec].invoke
end

# Do not run using bundle exec!
# FakeFS causes issues when bundler injects it into the require chain.
desc 'Run the elzar nightly specs'
RSpec::Core::RakeTask.new :elzar_nightly do |t|
  t.pattern = 'spec/elzar_recipes_spec.rb'
  t.rspec_opts = '-t ci'
end
