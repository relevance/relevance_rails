Setup Chef
----------

To setup chef recipes in provision/:

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
