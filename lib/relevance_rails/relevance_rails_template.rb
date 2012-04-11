require 'relevance_rails'
require 'json'

rvm_lib_path = "#{`echo $rvm_path`.strip}/lib"
$LOAD_PATH.unshift(rvm_lib_path) unless $LOAD_PATH.include?(rvm_lib_path)
require 'rvm'

def rvm_run(command)
  say_status :rvm_run, command
  RelevanceRails.rvm_run(command)
end

db = ['postgresql','mysql'].include?(options[:database]) ? options[:database] : 'mysql'
ruby_version = RelevanceRails.rvm_version

remove_file 'README.rdoc'
remove_file 'doc/README_FOR_APP'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file 'test'
remove_file 'Gemfile'
remove_file 'app/assets/images/rails.png'
remove_file 'app/views/layouts/application.html.erb'

generate(:relevance_file, app_name, db)

inside destination_root do
  env = RVM::Environment.new(ruby_version)
  say_status :create_gemset, app_name
  succ = env.gemset_create(app_name)
  env = RVM::Environment.new("#{ruby_version}@#{app_name}")
  say_status :gem, "install bundler"
  env.system('gem', 'install', 'bundler')
  say_status :bundle, "install"
  env.system('bundle', 'install')
end

git :init
append_file ".gitignore", "config/database.yml\n"
run 'cp config/database.example.yml config/database.yml'
git :add => "."
git :commit => "-a -m 'Initial commit'"

inside destination_root do
  env = RVM::Environment.new("#{ruby_version}@#{app_name}")
  env.system('rails','g','provision_config',db)
  #generate(:provision_config, db)
end

# implicit bundle
# Gabe & Alex come along and say "WTF?!"
