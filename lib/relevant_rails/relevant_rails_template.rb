RVM_RUBY = "ree-1.8.7-2012.02"
RVM_GEMSET = app_name

def rvm_run(command, config = {})
  run "rvm #{RVM_RUBY}@#{RVM_GEMSET} exec #{command}", config
end

run 'rm README'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm -rf test'
run 'rm Gemfile'
run 'rm app/assets/images/rails.png'
run 'rm app/views/layouts/application.html.erb'

generate(:relevant_gemfile)
generate(:relevant_default)

run "rvm #{RVM_RUBY} gemset create #{RVM_GEMSET}"
rvm_run "gem install bundler"
rvm_run "bundle install"

git :init
append_file ".gitignore", "config/database.yml\n"
run 'cp config/database.yml config/database.example.yml'
git :add => "."
git :commit => "-a -m 'Initial commit'"
