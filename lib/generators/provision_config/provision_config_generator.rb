require 'relevance_rails'
require 'rails/generators'

class ProvisionConfigGenerator < Rails::Generators::NamedBase

  desc "This generator configures the provision sub-directory with appropriate files."

  source_root File.expand_path("../templates", __FILE__)

  argument :database, :type => :string, :default => 'mysql'

  attr_reader :authorized_keys

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

  private

  def fetch_keys
    local_key = `ssh-add -L`.split("\n")
    local_key = [] unless $?.success?
    (local_key + RelevanceRails::PublicKeyFetcher.public_keys).uniq
  end
end
