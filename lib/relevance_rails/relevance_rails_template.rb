require 'relevance_rails'
require 'json'

def rvm_run(command, config = {})
  puts "#{command}..."
  RelevanceRails.rvm_run("rvm use #{RelevanceRails.rvm_version}@#{app_name} && #{command}")
end

run 'rm README.rdoc'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm -rf test'
run 'rm Gemfile'
run 'rm app/assets/images/rails.png'
run 'rm app/views/layouts/application.html.erb'

generate(:relevance_file, app_name, options[:database] || 'mysql')

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
run 'mv authorized_keys.json provision/data_bags/deploy/authorized_keys.json'
git :rm => 'authorized_keys.json'
git :add => 'provision/data_bags/deploy/authorized_keys.json'
git :add => 'provision/Vagrantfile'

json = JSON.parse File.read('provision/dna.json')
json['rails_app']['name'] = app_name
if RelevanceRails.rvm_version =~ /^ree-(.*)/i
  json['ruby_enterprise']['version'] = $1
  json['ruby_enterprise']['url'] = "http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-#{$1}"
  appstack_index = json['run_list'].find_index {|e| e[/^role\[.*_appstack\]$/] }
  json['run_list'][appstack_index] = 'role[enterprise_appstack]'
elsif RelevanceRails.rvm_version =~ /^ruby-(.*)/i
  json['ruby']['version'] = $1
  json['ruby']['url'] = "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-#{$1}.tar.gz"
  appstack_index = json['run_list'].find_index {|e| e[/^role\[.*_appstack\]$/] }
  json['run_list'][appstack_index] = 'role[ruby_appstack]'
else
  raise "Your ruby is NOT SUPPORTED. Please use ree or ruby."
end
run 'rm provision/dna.json'
create_file 'provision/dna.json', JSON.generate(json)
git :add => 'provision/dna.json'

git :commit => '-m "Merge Elzar as our provision subdirectory"'
