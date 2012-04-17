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

[![Build Status](https://secure.travis-ci.org/relevance/relevance_rails.png?branch=master)](http://travis-ci.org/relevance/relevance_rails)

Getting Started
---------------

For new projects:

````sh
$ gem install relevance_rails
$ relevance_rails new <your new project>
````

For existing projects, first add to your Gemfile:

    group :development, :test do
      gem 'relevance_rails'
    end

After a `bundle install`, pull in our chef recipes into provision/:

```sh
# defaults to mysql
$ rails g provision_config
# if using postgresql
$ rails g provision_config postgresql
```

Configuring bundled ssh keys
----------------------------

By default, relevance_rails bundles all your keys from `ssh-add -L` with your instance. For bundling
additional keys, you can create a ~/.relevance_rails/keys_git_url file and point it to a git repo that
has additional keys. Keys in that git repo should exist as top level *.pub files. You *MUST* have at
least one key to provision.

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
$ rake provision:ec2_and_generate NAME=qa
$ cap qa deploy:setup deploy
```

Provisioning with Vagrant
-------------------------

From your app's root directory:

```sh
$ cd provision
# pull in vagrant and chef
$ bundle install
$ vagrant up
```

Vagrant instance should be up at 172.25.5.5.

Supported Ruby Versions
-----------------------

Currently both Ruby 1.9.x and REE 1.8.7 are supported. relevance_rails
configures your Rails app (and Chef provisioning scripts) to require the version
of Ruby you used to invoke the relevance_rails executable. If relevance_rails is run
in a non-rvm environment, all installation occurs in the current gem environment. If in rvm,
the app is installed into its own rvm gemset.

Supported Databases
-------------------

Currently both MySQL and PostgreSQL are supported.  By default relevance_rails configures
your Rails app (and Chef provisioning scripts) to use MySQL.  However, if you use the
standard `--database=postgresql` Rails option, relevance_rails will use PostgreSQL.

Maintainer Notes
----------------

When QAing or doing local development of this gem, the gem must be built locally and creating
an app needs an additional flag.

    $ gem build relevance_rails.gemspec && gem install relevance_rails-VERSION.gem
    $ relevance_rails new APP --relevance-dev

Caveats
-------

Currently we only support Ruby 1.9.x, REE 1.8.7, Rails 3.2, MySQL, and PostgreSQL installed on Ubuntu.

Improvements
------------

Fork, do your work, and issue a pull request.

Issues
------

Open a github issue and I'll look at it next Friday.
