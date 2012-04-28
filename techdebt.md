* TECHDEBT BY COMPONENT *

* GENERAL
** move all general configuration to a ~/.relevance_rails.yml file (AWS stuff, keys git repo stuff)
** intermittent mysql::server failures (mysql server not up yet) on `vagrant up`. Attempt fix in site_cookbooks
** when generating an app with --database=postgresql, provision_config
   generator intermittently fails at the beginning with different gem not found
   errors. Generating the app more than once or inspecting the problem solves it
** provision_config generator intermittently can't detect current working directory which breaks
   git commands. Current solution of sprinkling Dir.chdir is a bandaid at best.

* Provisioning an instance
** Make the deployment generator idempotent
** Better error handling when the aws.yml is not present
