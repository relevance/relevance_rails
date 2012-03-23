class RelevanceFileGenerator < Rails::Generators::NamedBase

  desc "This generator creates a number of default Rails files."

  source_root File.expand_path("../templates", __FILE__)

  def copy_gemfile
    copy_file "Gemfile", "Gemfile"
  end

  def create_readme_markdown
    create_file "README.markdown", <<-README
# #{name}

## Getting Started

gem install bundler
# TODO other setup commands here
    README
  end

  def create_application_layout
    create_file 'app/views/layouts/application.html.haml', <<-LAYOUT
!!!
%html
  %head
    %title #{name}
  = stylesheet_link_tag :application
  = javascript_include_tag :application
  = csrf_meta_tag
  %body
    = yield
    LAYOUT
  end

  def create_rvmrc
    create_file ".rvmrc", "rvm use ree-1.8.7-2012.02@#{name}"
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

  def create_deploy
    create_file 'config/deploy.rb', <<-CAP_CONFIG
require 'bundler/capistrano'

set :application, "#{name}"
set :repository,  "."
set :deploy_via, :copy

set :scm, :git

set :deploy_to, "/var/www/apps/\#{application}"
default_run_options[:pty] = true
set :ssh_options, { :paranoid => false, :forward_agent => true }

set :copy_exclude, '.git/*'

set :stages, %w(vagrant)
set :default_stage, 'vagrant'

after "deploy:setup", "deploy:copy_shared_db_config"
after "deploy:create_symlink", "deploy:symlink_shared_db_config"

Dir['config/deploy/recipes/*.rb'].sort.each { |f| eval(File.read(f)) }
    CAP_CONFIG
  end

  def create_database_example_yml
    create_file 'config/database.example.yml', <<-DATABASE_CONFIG
development:
  adapter: mysql2
  encoding: utf8
  database: #{name}_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: mysql2
  encoding: utf8
  database: #{name}_test

production:
  adapter: mysql2
  encoding: utf8
  database: #{name}_production
    DATABASE_CONFIG
  end

  def create_authorized_key_data_bag
    authorized_keys = `ssh-add -L`.split("\n")
    authorized_keys.map! {|key| "\"#{key}\""}
    create_file 'authorized_keys.json', <<-AUTHORIZED_KEYS
{
  "id":"authorized_keys",
  "keys": [
#{authorized_keys.join(",\n")}
   ]
}
    AUTHORIZED_KEYS
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
