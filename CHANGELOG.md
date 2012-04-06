*v0.1.0*

* Provisioning can be done on existing apps
* Support multiple rubies - 1.9 and ree
* Add unit tests
* Can run acceptance tests on generated apps - rails g fixtures
* From provision to deploy is a 2 step process - rake provision:ec2 and rails g deployment
* Add more error handling
* Tentative support for multiple databases - postgresql and mysql

*v0.0.4*

* Add support for generating EC2 deployment environments
* 'rails g deployment <environment>' to generate a new environment
* REQUIRES the presence of ~/.relevance_rails/aws_config.yml
* Template aws_config.yml included with this gem.
* Newly generates EC2 deployment environments will be wired up as new cap stages.

*v0.0.3*

* Add support for multiple public keys pushed to converged hosts.
* Public keys are fetched from a git repo.
* Git repo url is stored in ~/.relevance_rails/keys_git_url
* Only the top level keys from the repo will be pushed to new hosts.
