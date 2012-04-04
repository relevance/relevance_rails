Relevance Rails
==============

Yo dawg, I heard you like automation, so I automated your automation so you can autopilot while you autopilot!

Rails 3 projects with every fiddly bit convened rather than configured. Includes:

* HAML and SCSS
* RSpec 2 with Relevance config niceties
* Factory Girl
* Mocha configured for mocking
* Capistrano deploy recipes
* A VM deployment target under provision

Getting Started
---------------

````sh
$ gem install relevance_rails
$ relevance_rails new <your new project>
````

Provisioning on EC2
-------------------

First create an aws config in ~/.relevance\_rails/aws\_config.yml.
An example config looks like this:

```yaml
aws_credentials:
  :aws_access_key_id: <your aws access key id>
  :aws_secret_access_key: <your aws secret access key>

server:
  creation_config:
    :flavor_id: <instance type, e.g. 'm1.large'>
    :image_id: <ami to bootstrap with. Must be some UBUNTU image. e.g. "ami-fd589594">
    :groups: <security group to place the new deployment in, e.g. "default">
    :key_name: <name of the public/private keypair to start instance with>
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    Include the RSA private key here. This should correspond to the keypair indicated
    by :key_name above.
    -----END RSA PRIVATE KEY-----
```

Now just provision your instance:

```sh
$ rails g deployment qa
$ cap qa deploy:setup deploy:cold
```

Supported Ruby Versions 
-----------------------

Currently both Ruby 1.9.2 and REE 1.8.7 are supported via RVM.  By default relevance_rails 
configures your Rails app (and Chef provisioning scripts) to rely on Ruby 1.9.2 unless you 
invoke the `relevance\_rails` executable using REE 1.8.7.

Supported Databases 
-------------------

Currently both MySQL and PostgreSQL are supported.  By default relevance_rails configures 
your Rails app (and Chef provisioning scripts) to use MySQL.  However, if you use the 
standard `--database=postgresql` Rails option, relevance_rails will use PostgreSQL. 

Maintainer Notes
----------------

When QAing or doing local development of this gem, the gem must be built and installed locally.


In order to test deployment, use the example below to package the relevance_rails gem:

    # Given a relevance_rails app "app" lives in "~/src/app"
    # And the relevance_rails source lives in "~/src/relevance_rails"
    ~/src/relevance_rails $ gem build relevance_rails.gemspec
    ~/src/relevance_rails $ cd ~/src/app
    ~/src/app $ gem install ../relevance_rails/relevance_rails-0.0.7.gem
    ~/src/app $ bundle package 
    ~/src/app $ git commit -m "Package gems" vendor/cache

Caveats
-------

Currently we only support Ruby 1.9.2, REE 1.8.7, Rails 3.2, MySQL, and PostgreSQL installed on Ubuntu.

Improvements
------------

Fork, do your work, and issue a pull request.

Issues
------

Open a github issue and I'll look at it next Friday.
