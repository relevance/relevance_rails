README = <<-README
#{app_name}
#{'#' * app_name.length}

## Dependencies

    # TODO document app dependencies

## Getting Started

    gem install bundler
    # TODO other setup commands here
README

BOOTSTRP = <<-BASH
#!/usr/bin/env bash

gem install bundler
bundle install
rake db:create db:migrate
BASH

after_bundler do
  remove_file "public/index.html"
  remove_file "public/favicon.ico"
  remove_file "app/assets/images/rails.png"

  remove_file "README.rdoc"
  create_file "README.md", README

  create_file "script/bootstrap", BOOTSTRP
  run "chmod +x script/bootstrap"

  run 'cp config/database.yml config/database.example.yml'

  if scrolls.include? 'git'
    append_file ".gitignore", "\nconfig/database.yml"
    append_file ".gitignore", "\npublic/system"
    run 'git rm --cached config/database.yml'
  end
end

after_everything do
  rake "db:migrate"
end

__END__

name: Rails Bootstrap
description: Basic Rails app bootstrapping
author: jdpace
