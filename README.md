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
$ cap qa deploy:setup deploy
```

Caveats
-------

Only supports REE 1.8.7, Rails 3.1 and MySQL right now.

Improvements
------------

Fork, do your work, and issue a pull request.

Issues
------

Open a github issue and I'll look at it next Friday.
