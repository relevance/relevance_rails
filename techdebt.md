* TECHDEBT BY COMPONENT *

* GENERAL
** remove heredocs, replace by erb templates
** move all general configuration to a ~/.relevance_rails.yml file (AWS stuff, keys git repo stuff)
** TESTING, at minimum an acceptance test script a human executes to ensure correctness across key functional areas
** cleaner rvm version detection - intermittenly picks up no version
** intermittent mysql::server failures (mysql server not up yet) on `vagrant up`. Attempt fix in site_cookbooks

* APP GENERATION
** If no git keys url file AND no ssh agent active, complain noisily and refuse to continue

* deployment generator
** Don't hardcode path to chef binstub, caused by ubuntu installing weirdness
** Make the deployment generator idempotent
** Better error handling when the aws.yml is not present
** On an uncaught exception, destroy the ec2 instances (?)
** DeploymentUtil.wait_for_ssh intermittently hangs
