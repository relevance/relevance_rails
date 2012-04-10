require 'relevance_rails/provision'

namespace :provision do
  desc 'Provision a deployable EC2 instance and generate Capistrano config'
  task :ec2_and_generate do
    server = RelevanceRails::Provision.create_ec2(ENV['NAME'])
    system('rails', 'generate', 'deployment', ENV['NAME'], server.public_ip_address)
  end

  desc 'Provision a deployable EC2 instance'
  task :ec2 do
    RelevanceRails::Provision.create_ec2(ENV['NAME'])
  end

  desc 'Stop your previously-provisioned EC2 instance'
  task :stop do
    RelevanceRails::Provision.stop_ec2
  end

  desc 'Destroy your previously-provisioned EC2 instance'
  task :destroy do
    RelevanceRails::Provision.destroy_ec2
  end
end
