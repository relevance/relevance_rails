require 'relevance_rails'
require 'rails/generators'

class ProvisionConfigGenerator < Rails::Generators::NamedBase

  desc "This generator configures the provision sub-directory with appropriate files."

  source_root File.expand_path("../templates", __FILE__)

  argument :database, :type => :string, :default => 'mysql'

  attr_reader :authorized_keys

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
    if (@authorized_keys = fetch_keys).empty?
      abort "No ssh keys were found! Check ssh-add -L and your keys_git_url config."
    end
    @authorized_keys.map! {|key| "\"#{key}\""}
    template('authorized_keys.json.erb', 'provision/data_bags/deploy/authorized_keys.json', {:force => true})
  end

  def create_dna_json
    path = File.expand_path('provision/dna.json', destination_root)
    json = JSON.parse File.binread(path)
    json['rails_app']['name'] = name
    # This generator may not receive a working directory;
    # and we pull data by shelling out to RVM about the ruby
    # version. This sets the directory explicitly beforehand.
    Dir.chdir(destination_root)
    RelevanceRails::ChefDNA.gene_splice(json,database)
    create_file('provision/dna.json', JSON.generate(json), {:force => true})
  end

  def commit_changes
    git :add => 'provision/data_bags/deploy/authorized_keys.json'
    git :add => 'provision/Vagrantfile'
    git :add => 'provision/dna.json'
    git :commit => '-m "Merge Elzar as our provision subdirectory"'
  end

  private

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
    git :add => destination
  end


  def fetch_keys
    local_keys = `ssh-add -L`.split("\n")
    local_keys = [] unless $?.success?
    (local_keys + RelevanceRails::PublicKeyFetcher.public_keys).uniq
  end
end
