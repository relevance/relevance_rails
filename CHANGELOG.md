*v0.2.0*

* Depend on slushy for provisioning
* Depend on elzar as a gem
** elzar's chef recipes stay in elzar
** relevance_rails has no knowledge of elzar's recipe internals
* Search for local ssh public keys before querying ssh-agent
* Improved UX around retrying failed commands
* Fix fixtures generator
* Generated Rails app depends on haml <= 3.1.4 due to haml 3.1.5 bug

*v0.1.2*

* add streaming output from chef convergence using a fog monkeypatch
* retry apt-get command failures
* add --help
* add support for rvm > 1.12.0

*v0.1.1.alpha*

* Ruby manager agnostic - can use rvm, system ruby or rbenv
* new APP --relevance-dev for simple QA development
* Fix sudo on deploy user
* provision rvmrc mirrors app's rvmrc
* existing app users have a deploy that just works
* fail fast in more places
* stop and destroy provisioned instances from commandline

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
