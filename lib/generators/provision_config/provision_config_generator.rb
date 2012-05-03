require 'relevance_rails'
require 'tempfile'
require 'rails/generators'

class ProvisionConfigGenerator < Rails::Generators::Base
  include RelevanceRails::GeneratorOverrides

  desc "This generator configures the provision sub-directory with appropriate files."

  source_root File.expand_path("../templates", __FILE__)

  argument :database, :type => :string, :default => 'mysql'

  attr_reader :authorized_keys

  # This generator may not receive a working directory;
  # and we pull data by shelling out to RVM about the ruby
  # version. This sets the directory explicitly beforehand.
  def change_directory
    Dir.chdir(destination_root)
  end

  def check_git_status
    unless `git status`[/working directory clean/]
      abort "Your git repository is dirty. Clean up before reinvoking this command."
    end
  end

  def check_authorized_keys
    if (@authorized_keys = fetch_keys).empty?
      abort <<-EOF
No SSH public keys were found!

To ensure you have remote access to your servers, an SSH public key must be available from at least one of these sources:
- local file (~/.ssh/id_rsa.pub, ~/.ssh/id_dsa.pub, or ~/.ssh/id_ecdsa.pub)
- ssh-agent (by running `ssh-add -L`)
- public keys git repo (URL to repo specified in ~/.relevance_rails/key_git_url)
      EOF
    end
  end

  def create_capistrano_files
    backup_copy_file 'Capfile', 'Capfile'
    backup_template 'deploy.rb.erb', 'config/deploy.rb'
    backup_copy_file 'recipes_deploy.rb', 'config/deploy/recipes/deploy.rb'
    backup_copy_file 'vagrant.rb', 'config/deploy/vagrant.rb'
    git :commit => '-m "Add Capistrano files"'
  end

  def fetch_elzar
    git :remote => 'add -f elzar git://github.com/relevance/elzar.git'
    git :merge => '-s ours --no-commit elzar/master'
    git :"read-tree" => '--prefix=provision/ -u elzar/master'
    gsub_file 'provision/Vagrantfile', /config\.vm\.host_name(\s+)= .*$/,
      "config.vm.host_name\\1= '#{name.gsub('_','-')}.local'"
  end

  def create_authorized_key_data_bag
    content = {
      "id"   => "authorized_keys",
      "keys" => @authorized_keys,
    }
    create_file('provision/data_bags/deploy/authorized_keys.json', JSON.generate(content), {:force => true})
  end

  def create_dna_json
    path = File.expand_path('provision/dna.json', destination_root)
    content = JSON.parse(File.binread(path))
    content['rails_app']['name'] = name
    RelevanceRails::ChefDNA.gene_splice(content, database)
    create_file('provision/dna.json', JSON.generate(content), {:force => true})
  end

  def create_rvmrc
    if File.exists?(rvmrc = Rails.root.join('.rvmrc'))
      create_file('provision/.rvmrc', File.read(rvmrc), :force => true)
      git :add => 'provision/.rvmrc'
    else
      remove_file 'provision/.rvmrc'
      git :rm => 'provision/.rvmrc'
    end
  end

  def commit_changes
    git :add => 'provision/data_bags/deploy/authorized_keys.json'
    git :add => 'provision/Vagrantfile'
    git :add => 'provision/dna.json'
    git :commit => '-m "Merge Elzar as our provision subdirectory"'
  end

  private

  def name
    Rails.application.class.name.split('::').first.underscore
  end

  def backup_copy_file(source, destination)
    backup_manip_file(source, destination, :copy_file)
  end

  def backup_template(source, destination)
    backup_manip_file(source, destination, :template)
  end

  def backup_manip_file(source, destination, operation)
    if File.exists?(destination)
      backup_file = "#{destination}.bak"
      say_status :backup, "#{destination} to #{backup_file}"
      git :mv => "#{destination} #{backup_file}"
    end

    send(operation, source, destination)
    # git wasn't picking up current directory
    change_directory
    git :add => destination
  end

  def fetch_keys
    keys = local_keys
    keys = ssh_agent_keys if keys.empty?
    keys += RelevanceRails::PublicKeyFetcher.public_keys
    keys.uniq
  end

  def local_keys
    key_files = [
      File.expand_path("~/.ssh/id_dsa.pub"),
      File.expand_path("~/.ssh/id_ecdsa.pub"),
      File.expand_path("~/.ssh/id_rsa.pub"),
    ]
    key_files.select { |p| File.exist?(p) }.take(1).map { |p| split_keys(File.read(p)) }.flatten(1)
  end

  def ssh_agent_keys
    keys = split_keys(`ssh-add -L`)
    $?.success? ? keys : []
  end

  def split_keys(s)
    s.split("\n").reject { |k| k.blank? }
  end
end
