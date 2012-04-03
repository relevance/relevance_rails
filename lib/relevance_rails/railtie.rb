require 'rails'

module RelevanceRails
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/provision.rake'
    end
  end
end
