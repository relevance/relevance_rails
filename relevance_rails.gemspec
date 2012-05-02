# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "relevance_rails/version"

Gem::Specification.new do |s|
  s.name        = "relevance_rails"
  s.version     = RelevanceRails::VERSION
  s.homepage    = "http://github.com/relevance/relevance_rails"
  s.authors     = ["Alex Redington"]
  s.email       = ["alex.redington@thinkrelevance.com"]
  s.summary     = %q{Rails 3 Relevance style, with all infrastructure bits automated away.}
  s.description = %q{A Rails 3 wrapper which forces template use and includes a plethora of generators for standard Relevance bits.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.executables   = ['relevance_rails']

  # be aware that we're monkey-patching fog in fog_ext/ssh.rb;
  # if we update fog, that monkey-patch might need to be
  # revisited
  s.add_runtime_dependency 'fog', '1.3.1'
  s.add_runtime_dependency 'rails', '~> 3.2'
  s.add_runtime_dependency 'slushy', '~> 0.1.1'
  s.add_runtime_dependency 'thor', '~> 0.14.6'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '~> 0.9.2.2'
  s.add_development_dependency 'rspec'
end
