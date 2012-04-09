require 'relevance_rails'

class RelevanceFileGenerator < Rails::Generators::NamedBase

  desc "This generator creates a number of default Rails files."

  source_root File.expand_path("../templates", __FILE__)

  argument :database, :type => :string, :default => 'mysql'

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

  def create_database_example_yml
    if database == 'mysql'
      template 'database.example.yml.mysql.erb', 'config/database.example.yml'
    elsif database == 'postgresql'
      template 'database.example.yml.postgresql.erb', 'config/database.example.yml'
    else
      create_file 'database.example.yml', "Don't know how to make a template for database: #{database}"
    end
  end

  def fix_session_store
    gsub_file 'config/initializers/session_store.rb', 'key:', ':key =>'
  end

  def fix_wrap_parameters
    gsub_file 'config/initializers/wrap_parameters.rb', 'format:', ':format =>'
  end

end
