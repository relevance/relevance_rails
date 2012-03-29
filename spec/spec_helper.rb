require 'capybara/rspec'
require 'capybara/dsl'

RSpec.configure do |config|
  config.include Capybara::DSL
  config.filter_run :focused => true
  config.filter_run_excluding :disabled => true
  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :disabled => true
  config.alias_example_to :they
  config.run_all_when_everything_filtered = true
end

Capybara.current_driver = :selenium
Capybara.run_server = false
# vagrant or ec2 instance is up and running ...
Capybara.app_host = 'http://localhost:3000'
# Capybara.app_host = 'http://184.72.185.16'
