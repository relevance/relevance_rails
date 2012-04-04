require 'capybara/rspec'
require 'capybara/dsl'
require 'relevance_rails'

module TestHelpers

  def silence(&block)
    capture_stdout do
      capture_stderr do
        block.call
      end
    end
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def capture_stderr(&block)
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include TestHelpers
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
