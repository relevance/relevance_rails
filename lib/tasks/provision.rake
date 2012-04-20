require 'relevance_rails/provision'

namespace :provision do
  desc 'Provision a deployable EC2 instance and generate Capistrano config'
  task :ec2_and_generate do
    server_name = "#{Rails.application.class.parent_name} #{ENV['NAME']}"
    server = RelevanceRails::Provision.create_ec2(server_name)
    system('rails', 'generate', 'deployment', ENV['NAME'], server.public_ip_address)
  end

  desc 'Provision a deployable EC2 instance'
  task :ec2 do
    server_name = "#{Rails.application.class.parent_name} #{ENV['NAME']}"
    RelevanceRails::Provision.create_ec2(server_name)
  end

  desc 'Stop your previously-provisioned EC2 instance'
  task :stop do
    RelevanceRails::Provision.stop_ec2
  end

  desc 'Destroy your previously-provisioned EC2 instance'
  task :destroy do
    RelevanceRails::Provision.destroy_ec2
  end
  
  desc 'Return the current public DNS name for your previously-provisioned EC2 instance'
  task :current_dns do
    RelevanceRails::Provision.current_dns
  end
end
