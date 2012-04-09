* TECHDEBT BY COMPONENT *

* GENERAL
** remove heredocs, replace by erb templates
** move all general configuration to a ~/.relevance_rails.yml file (AWS stuff, keys git repo stuff)
** cleaner rvm version detection - intermittenly picks up no version
** intermittent mysql::server failures (mysql server not up yet) on `vagrant up`. Attempt fix in site_cookbooks
** intermittent setup failure - apt-get update fails with 404s or ruby not found
** when generating an app with --database=postgresql, provision_config
   generator intermittently fails at the beginning with different gem not found
   errors. Generating the app more than once or inspecting the problem solves it

* Provisioning an instance
** Don't hardcode path to chef binstub, caused by ubuntu installing weirdness
** Make the deployment generator idempotent
** Better error handling when the aws.yml is not present
** On an uncaught exception, destroy the ec2 instances (?)
** RelevanceRails::Provision.wait_for_ssh intermittently hangs
