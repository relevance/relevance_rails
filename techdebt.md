* TECHDEBT BY COMPONENT *

* GENERAL
** move all general configuration to a ~/.relevance_rails.yml file (AWS stuff, keys git repo stuff)
** intermittent mysql::server failures (mysql server not up yet) on `vagrant up`. Attempt fix in site_cookbooks
** when generating an app with --database=postgresql, provision_config
   generator intermittently fails at the beginning with different gem not found
   errors. Generating the app more than once or inspecting the problem solves it
** provision_config generator intermittently can't detect current working directory which breaks
   git commands. Current solution of sprinkling Dir.chdir is a bandaid at best.
** Make the deployment generator idempotent
** Have pg and mysql recipes depend on a unified gem install method. This method would call
   gem_package for mri and ree_gem for ree. When this is done, we can add --dont-install-useful-gems
   back to the ree installer.
** Upgrade to haml > 3.1.5 once AbstractController::Rendering#render_to_body bug is resolved
