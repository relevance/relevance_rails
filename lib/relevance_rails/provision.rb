require 'fog'
require 'thor'

module RelevanceRails
  module Provision
    def self.create_ec2(name = nil)
      abort "Please provide a $NAME" unless name
      server = provision_ec2_instances(name)
      wait_for_ssh server
      run_commands server
    end

    def self.stop_ec2
      return unless ENV["FORCE"] == "true" || Thor::Shell::Basic.new.yes?("Are you sure you want to shut down EC2 instance #{instance_id}?")
      puts "Shutting down EC2 instance #{instance_id}..."
      server = fog_connection.servers.get(instance_id)
      server.stop
      server.wait_for { state == "stopped" }
      puts "Done!"
    end

    def self.destroy_ec2
      return unless ENV["FORCE"] == "true" || Thor::Shell::Basic.new.yes?("Are you sure you want to destroy EC2 instance #{instance_id}?")
      puts "Destroying EC2 instance #{instance_id}..."
      server = fog_connection.servers.get(instance_id)
      server.destroy
      server.wait_for { state == "terminated" }
      puts "Removing config/ec2_instance.txt..."
      File.delete('config/ec2_instance.txt')
      puts "Done!"
    end

    private

    def self.instance_id
      @instance_id ||= File.read('config/ec2_instance.txt').chomp
    end

    def self.config
      @config ||= YAML::load(File.read(File.expand_path("~/.relevance_rails/aws_config.yml")))
    end

    def self.fog_connection
      @fog_connection ||= Fog::Compute.new(config['aws_credentials'].merge(:provider => 'AWS'))
    end

    def self.provision_ec2_instances(name)
      puts "Provisioning an instance..."
      original_timeout = Fog.timeout
      Fog.timeout = 60
      server = fog_connection.servers.create(config['server']['creation_config'])
      fog_connection.tags.create(:key => 'Name',
                      :value => "#{Rails.application.class.parent_name} #{name}",
                      :resource_id => server.id)
      server.private_key = config['server']['private_key']
      
      File.open("config/ec2_instance.txt", "w") do |f|
        f.puts(server.id)
      end

      puts "Provisioned!"
      server
    end
    
    def self.run_commands(server)
      puts "Updating apt cache..."
      run_command(server, 'sudo apt-get update')
      puts "Installing ruby..."
      run_command(server, 'sudo apt-get -y install ruby')
      puts "Installing rubygems..."
      run_command(server, 'sudo apt-get -y install rubygems1.8')
      puts "Installing chef..."
      run_command(server, 'sudo gem install chef --no-ri --no-rdoc --version 0.10.8')
      puts "Copying chef resources from provision directory.."
      server.scp("#{Rails.root.join('provision')}/", '/tmp/chef-solo', :recursive => true)
      puts "Converging server, this may take a while (10-20 minutes)"
      run_command(server, 'cd /tmp/chef-solo && sudo /var/lib/gems/1.8/bin/chef-solo -c solo.rb -j dna.json')

      puts "Server Instance: #{server.id}"
      puts "Server IP: #{server.public_ip_address}"
      Fog.timeout = original_timeout
      server
    end

    def self.run_command(server, command)
      jobs = server.ssh(command)
      exit 1 unless jobs_succeeded?(jobs)
    end

    def self.wait_for_ssh(server)
      puts "Waiting for ssh connectivity..."
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
          puts "Connecting to Amazon refused. Attempt #{attempts+1}..."
          attempts += 1
          last_error = e
        end
      end
      raise last_error unless succeeded
      puts "Server up and listening for SSH!"
    end

    def self.jobs_succeeded?(jobs)
      return true if jobs.all? { |job| job.status == 0 }
      jobs.each do |job|
        puts "----------------------"
        puts "Command '#{job.command}'"
        puts "STDOUT: #{job.stdout}"
        puts "STDERR: #{job.stderr}"
        puts "----------------------"
      end
      false
    end

  end
end
