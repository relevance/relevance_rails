require 'fog'

module DeploymentUtil
  def self.wait_for_ssh(server)
    server.wait_for { ready? }
    succeeded = false
    attempts = 0
    last_error = nil
    until succeeded || attempts > 4
      sleep 10
      begin
        server.ssh('ls')
        succeeded = true
      rescue Errno::ECONNREFUSED => e
        puts "Connection #{attempts} refused, retrying..."
        attempts += 1
        last_error = e
      end
    end
    raise last_error unless succeeded
    puts "Server up and listening for SSH..."
  end

  def self.inject_stage(name)
    new_contents = ""
    File.new(Rails.root.join('config','deploy.rb')).readlines.each do |line|
      unless line =~ /^set :stages, (.*)$/
        new_contents << line
      else
        stages = eval($1)
        stages << name
        stage_array_contents = stages.map{|stage| "\"#{stage}\""}.join(', ')
        new_contents << "set :stages, [#{stage_array_contents}]\n"
      end
    end
    File.open(Rails.root.join('config','deploy.rb'),'w') do |file|
      file.write new_contents
    end
  end

  def self.print_errors(jobs)
    return if jobs.all? { |job| job.status == 0 }
    jobs.each do |job|
      puts "----------------------"
      puts "Running #{job.command}"
      puts "STDOUT: #{job.stdout}"
      puts "STDERR: #{job.stderr}"
      puts "----------------------"
    end
  end
end

class DeploymentGenerator < Rails::Generators::NamedBase

  desc "This generator creates an ec2 instance which can be deployed to."

  def provision_ec2_instances
    config = YAML::load(File.read(File.expand_path("~/.relevance_rails/aws_config.yml")))
    fog = Fog::Compute.new(config['aws_credentials'].merge(:provider => 'AWS'))
    server = fog.servers.create(config['server']['creation_config'])
    fog.tags.create(:key => 'Name', :value => "#{Rails.application.class.parent_name} #{name}", :resource_id => server.id)
    server.private_key = config['server']['private_key']
    DeploymentUtil.wait_for_ssh server
    jobs = []
    puts "Updating apt cache..."
    jobs += server.ssh('sudo apt-get update')
    puts "Installing ruby..."
    jobs += server.ssh('sudo apt-get -y install ruby')
    puts "Installing rubygems..."
    jobs += server.ssh('sudo apt-get -y install rubygems1.8')
    puts "Installing chef..."
    jobs += server.ssh('sudo gem install chef --no-ri --no-rdoc --version 0.10.8')
    puts "Copying chef resources from provision directory.."
    server.scp("#{Rails.root.join('provision')}/", '/tmp/chef-solo', :recursive => true)
    puts "Converging server, this may take a while (10-20 minutes)"
    jobs += server.ssh('cd /tmp/chef-solo && sudo /var/lib/gems/1.8/bin/chef-solo -c solo.rb -j dna.json')
    DeploymentUtil.print_errors(jobs)
    @deployment_ip_address = server.public_ip_address
  end

  def write_stage_file
    create_file "config/deploy/#{name}.rb", <<-DEPLOY_STAGE
set :user, 'deploy'

role :web, "#{@deployment_ip_address}"
role :app, "#{@deployment_ip_address}"
role :db,  "#{@deployment_ip_address}", :primary => true
    DEPLOY_STAGE
  end

  def inject_new_deployment_to_stages
    DeploymentUtil.inject_stage(name)
  end
end
