require 'fog'
require 'thor'

module RelevanceRails
  module Provision
    def self.create_ec2(name = nil)
      abort "Please provide a $NAME" unless name
      provision_ec2_instances(name)
    end

    def self.stop_ec2
      instance_id = File.read('config/ec2_instance.txt').chomp
      return unless Thor::Shell::Basic.new.yes?("Are you sure you want to shut down EC2 instance #{instance_id}?")
      puts "Shutting down EC2 instance #{instance_id}..."
      server = fog_connection.servers.get(instance_id)
      server.stop
      server.wait_for { state == "stopped" }
      puts "Done!"
    end

    def self.destroy_ec2
      instance_id = File.read('config/ec2_instance.txt').chomp
      return unless Thor::Shell::Basic.new.yes?("Are you sure you want to destroy EC2 instance #{instance_id}?")
      puts "Destroying EC2 instance #{instance_id}..."
      server = fog_connection.servers.get(instance_id)
      server.destroy
      server.wait_for { state == "terminated" }
      puts "Removing config/ec2_instance.txt..."
      File.delete('config/ec2_instance.txt')
      puts "Done!"
    end

    private

    def self.config
      @config ||= YAML::load(File.read(File.expand_path("~/.relevance_rails/aws_config.yml")))
    end

    def self.fog_connection
      @fog_connection ||= Fog::Compute.new(config['aws_credentials'].merge(:provider => 'AWS'))
    end

    def self.provision_ec2_instances(name)
      server = fog_connection.servers.create(config['server']['creation_config'])
      fog_connection.tags.create(:key => 'Name',
                      :value => "#{Rails.application.class.parent_name} #{name}",
                      :resource_id => server.id)
      server.private_key = config['server']['private_key']
      wait_for_ssh server

      File.open("config/ec2_instance.txt", "w") do |f|
        f.puts(server.id)
      end

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
      print_errors(jobs)
      puts "Server Instance: #{server.id}"
      puts "Server IP: #{server.public_ip_address}"
    end

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
end
