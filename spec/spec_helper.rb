require 'capybara/rspec'
require 'capybara/dsl'
require 'relevance_rails'

module TestHelpers
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

  # wrapper around raise_error that captures stderr
  def should_abort_with(msg)
    capture_stderr do
      expect do
        yield
      end.to raise_error SystemExit, msg
    end
  end
end

RSpec.configure do |config|
  if ENV['ACCEPTANCE']
    config.include Capybara::DSL
    config.filter_run :acceptance => true
    config.run_all_when_everything_filtered = false
  else
    config.include TestHelpers
    config.filter_run :focused => true
    config.filter_run_excluding :acceptance => true
    config.filter_run_excluding :disabled => true
    config.run_all_when_everything_filtered = true
  end

  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :disabled => true
  config.alias_example_to :they
end

Capybara.current_driver = :selenium
Capybara.run_server = false
#Capybara.app_host = 'http://' + (ENV["ACCEPTANCE_HOST"] || 'localhost:3000')
Capybara.app_host = ENV["ACCEPTANCE_HOST"] || 'http://localhost:3000'
