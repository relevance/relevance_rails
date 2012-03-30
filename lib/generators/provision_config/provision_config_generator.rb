class ProvisionConfigGenerator < Rails::Generators::NamedBase

  desc "This generator configures the provision sub-directory with appropriate files."

  source_root File.expand_path("../templates", __FILE__)

  argument :database, :type => :string, :default => 'mysql'

  attr_reader :authorized_keys

  def create_authorized_key_data_bag
    @authorized_keys = (`ssh-add -L`.split("\n") + RelevanceRails::PublicKeyFetcher.public_keys).uniq
    @authorized_keys.map! {|key| "\"#{key}\""}
    template 'authorized_keys.json.erb', 'authorized_keys.json'
  end

  def create_dna_json
    json = JSON.parse File.read('provision/dna.json')
    json['rails_app']['name'] = name
    RelevanceRails::ChefDNA.gene_splice(json,database)
    run 'rm provision/dna.json'
    create_file 'provision/dna.json', JSON.generate(json)
  end

end
