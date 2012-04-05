require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new
task :default => :spec

desc 'Run the acceptance specs'
task :acceptance do
  ENV["ACCEPTANCE"] = "true"
  Rake::Task[:spec].invoke
end
