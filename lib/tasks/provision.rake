require 'relevance_rails/provision'

namespace :provision do
  desc 'Provision a deployable EC2 instance'
  task :ec2 do
    RelevanceRails::Provision.create_ec2(ENV['NAME'])
  end
end
