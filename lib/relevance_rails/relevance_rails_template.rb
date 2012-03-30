require 'relevance_rails'
require 'json'

def rvm_run(command, config = {})
  say_status :rvm_run, command
  RelevanceRails.rvm_run("rvm use #{RelevanceRails.rvm_version}@#{app_name} && #{command}")
end

db = ['postgresql','mysql'].include?(options[:database]) ? options[:database] : 'mysql'

remove_file 'README.rdoc'
remove_file 'doc/README_FOR_APP'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file '-rf test'
remove_file 'Gemfile'
remove_file 'app/assets/images/rails.png'
remove_file 'app/views/layouts/application.html.erb'

generate(:relevance_file, app_name, db)

rvm_run "rvm gemset create #{app_name}"
rvm_run "gem install bundler"
rvm_run "bundle install"

git :init
append_file ".gitignore", "config/database.yml\n"
run 'cp config/database.example.yml config/database.yml'
git :add => "."
git :commit => "-a -m 'Initial commit'"

git :remote => 'add -f elzar git://github.com/relevance/elzar.git'
git :merge => '-s ours --no-commit elzar/master'
git :"read-tree" => '--prefix=provision/ -u elzar/master'
gsub_file 'provision/Vagrantfile', /config\.vm\.host_name(\s+)= .*$/, "config.vm.host_name\\1= '#{app_name.gsub('_','-')}.local'"
generate(:provision_config, app_name, db)
git :add => 'provision/data_bags/deploy/authorized_keys.json'
git :add => 'provision/Vagrantfile'
git :add => 'provision/dna.json'

git :commit => '-m "Merge Elzar as our provision subdirectory"'
