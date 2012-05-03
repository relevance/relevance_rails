require 'fog'
require 'thor'
require 'relevance_rails/fog_ext/ssh'
require 'slushy'

module RelevanceRails
  module Provision
    CONFIG_FILE = 'config/ec2_instance.txt'

    def self.create_ec2(name = nil)
      abort "Please provide a $NAME" unless name
      slushy = provision_ec2_instances(name)
      slushy.bootstrap
      slushy.converge Rails.root.join('provision')
      server = slushy.server
      puts "Server Instance: #{server.id}"
      puts "Server IP: #{server.public_ip_address}"
      server
    end

    def self.stop_ec2
      return unless (ENV["FORCE"] == "true") || Thor::Shell::Basic.new.yes?("Are you sure you want to shut down EC2 instance #{instance_id}?")
      puts "Shutting down EC2 instance #{instance_id}..."
      slushy = Slushy::Instance.new(fog_connection, instance_id)
      slushy.stop
      puts "Done!"
    end

    def self.destroy_ec2
      return unless (ENV["FORCE"] == "true") || Thor::Shell::Basic.new.yes?("Are you sure you want to destroy EC2 instance #{instance_id}?")
      puts "Destroying EC2 instance #{instance_id}..."
      slushy = Slushy::Instance.new(fog_connection, instance_id)
      slushy.terminate
      puts "Removing #{CONFIG_FILE}..."
      File.delete(CONFIG_FILE)
      puts "Done!"
    end

    def self.current_dns
      puts current_server.reload.dns_name
    end

    def self.current_server
      fog_connection.servers.get(instance_id)
    end

    private

    def self.instance_id
      @instance_id ||= File.read(CONFIG_FILE).chomp
    end

    def self.config
      @config ||= YAML::load(File.read(File.expand_path("~/.relevance_rails/aws_config.yml")))
    end

    def self.fog_connection
      @fog_connection ||= Fog::Compute.new(config['aws_credentials'].merge(:provider => 'AWS'))
    end

    def self.provision_ec2_instances(name)
      puts "Provisioning an instance..."
      conf = config['server']['creation_config']
      conf['tags'] = {'Name' => name}

      slushy = Slushy::Instance.launch(fog_connection, conf)
      slushy.server.private_key = config['server']['private_key']
      File.open(CONFIG_FILE, "w") { |f| f.puts(slushy.server.id) }
      puts "Provisioned!"
      slushy
    end
  end
end
