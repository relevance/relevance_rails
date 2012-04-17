require 'relevance_rails'
require 'json'

db = ['postgresql','mysql'].include?(options[:database]) ? options[:database] : 'mysql'

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
  run "gem install bundler"
  run "bundle install"
end

git :init
append_file ".gitignore", "config/database.yml\n"
run 'cp config/database.example.yml config/database.yml'
git :add => "."
git :commit => "-a -m 'Initial commit'"

inside destination_root do
  generate(:provision_config, db)
end
