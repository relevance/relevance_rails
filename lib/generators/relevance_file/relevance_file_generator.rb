require 'relevance_rails'

class RelevanceFileGenerator < Rails::Generators::NamedBase

  desc "This generator creates a number of default Rails files."

  source_root File.expand_path("../templates", __FILE__)

  argument :database, :type => :string, :default => 'mysql'

  attr_reader :authorized_keys

  def copy_gemfile
    template "Gemfile.erb", "Gemfile"
  end

  def create_readme_markdown
    template "README.markdown.erb", "README.markdown"
  end

  def create_application_layout
    template 'application.html.haml.erb', 'app/views/layouts/application.html.haml'
  end

  def create_rvmrc
    create_file ".rvmrc", "rvm use #{RelevanceRails.rvm_version}@#{name}"
  end

  def create_rspec
    create_file '.rspec', '--colour'
  end

  def copy_spec_helper
    copy_file 'spec_helper.rb', 'spec/spec_helper.rb'
  end

  def copy_capfile
    copy_file 'Capfile', 'Capfile'
  end

  def copy_deployment_generator
    copy_file 'deployment_generator.rb', 'lib/generators/deployment/deployment_generator.rb'
  end

  def create_deploy
    template 'deploy.rb.erb', 'config/deploy.rb'
  end

  def create_database_example_yml
    if database == 'mysql'
      template 'database.example.yml.mysql.erb', 'config/database.example.yml'
    elsif database =~ /postgres/
      template 'database.example.yml.postgresql.erb', 'config/database.example.yml'
    end
  end

  def create_authorized_key_data_bag
    @authorized_keys = (`ssh-add -L`.split("\n") + RelevanceRails::PublicKeyFetcher.public_keys).uniq
    @authorized_keys.map! {|key| "\"#{key}\""}
    template 'authorized_keys.json.erb', 'authorized_keys.json'
  end

  def copy_deploy_recipes
    copy_file 'recipes_deploy.rb', 'config/deploy/recipes/deploy.rb'
  end

  def copy_vagrant_stage
    copy_file 'vagrant.rb', 'config/deploy/vagrant.rb'
  end

  def fix_session_store
    gsub_file 'config/initializers/session_store.rb', 'key:', ':key =>'
  end

  def fix_wrap_parameters
    gsub_file 'config/initializers/wrap_parameters.rb', 'format:', ':format =>'
  end

end
