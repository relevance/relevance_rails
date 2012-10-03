require 'relevance_rails'

RSpec.configure do |config|
  config.filter_run_excluding :disabled => true
  config.run_all_when_everything_filtered = true

  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :disabled => true
  config.alias_example_to :they
end
