namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :copy_shared_db_config do
    run "mkdir -p #{shared_path}/config"
    example_config_contents = File.read('config/database.example.yml')
    put(example_config_contents, "#{shared_path}/config/database.yml", :via => :scp)
  end

  task :symlink_shared_db_config do
    run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
  end
end
