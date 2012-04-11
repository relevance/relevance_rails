class DeploymentGenerator < Rails::Generators::NamedBase
  desc "Generates and updates capistrano config for a new deployment target"
  argument :hostname, :type => :string

  def write_stage_file
    create_file "config/deploy/#{name}.rb", <<-DEPLOY_STAGE
set :user, 'deploy'
set :use_sudo, false

role :web, "#{hostname}"
role :app, "#{hostname}"
role :db,  "#{hostname}", :primary => true
    DEPLOY_STAGE
  end

  def inject_new_deployment_to_stages
    new_contents = ""
    File.new(Rails.root.join('config','deploy.rb')).readlines.each do |line|
      unless line =~ /^set :stages, (.*)$/
        new_contents << line
      else
        stages = eval($1)
        stages << name
        stages.uniq!
        stage_array_contents = stages.map{|stage| "\"#{stage}\""}.join(', ')
        new_contents << "set :stages, [#{stage_array_contents}]\n"
      end
    end
    File.open(Rails.root.join('config','deploy.rb'),'w') do |file|
      file.write new_contents
    end
  end
end
