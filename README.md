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

For existing projects, please note we *only* support Rails 3.2 and higher!  To add to an existing project, first add to your Gemfile:

    group :development, :test do
      gem 'relevance_rails'
    end


Using relevance_rails
---------------------

[See USAGE](https://github.com/relevance/relevance_rails/blob/master/USAGE.md)


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
