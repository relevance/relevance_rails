gem 'devise'

inject_into_file 'config/environments/development.rb', "\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n", :after => "Application.configure do"
inject_into_file 'config/environments/test.rb',        "\n  config.action_mailer.default_url_options = { :host => 'localhost:7000' }\n", :after => "Application.configure do"
inject_into_file 'config/environments/production.rb',  "\n  config.action_mailer.default_url_options = { :host => '#{app_name}.com' }\n", :after => "Application.configure do"

after_bundler do
  generate 'devise:install'

  devise_models = config['devise_models'].split(/[\s,]+/)
  devise_models.each do |model|
    generate "devise #{model}"
  end

  generate "devise:views"
end

__END__

name: Devise
description: Use Devise for Authentication
author: jdpace

category: authentication
exclusive: authentication

run_before: [active_admin]

config:
  - devise_models:
      type: string
      prompt: "Which models would you like to generate for authentication, space/comma delimited (e.g. User)?"
