set :user, 'deploy'
set :use_sudo, false

role :web, "172.25.5.5"
role :app, "172.25.5.5"
role :db,  "172.25.5.5", :primary => true
