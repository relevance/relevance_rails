* TECHDEBT BY COMPONENT *

* GENERAL
** remove heredocs, replace by erb templates
** move all general configuration to a ~/.relevance_rails.yml file (AWS stuff, keys git repo stuff)

* APP GENERATION
** If no git keys url file AND no ssh agent active, complain noisily and refuse to continue

* deployment generator
** Don't hardcode path to chef binstub, caused by ubuntu installing weirdness
** Make the deployment generator idempotent
** Better error handling when the aws.yml is not present