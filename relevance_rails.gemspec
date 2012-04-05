# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "relevance_rails/version"

Gem::Specification.new do |s|
  s.name        = "relevance_rails"
  s.version     = RelevanceRails::VERSION
  s.authors     = ["Alex Redington"]
  s.email       = ["alex.redington@thinkrelevance.com"]
  s.homepage    = ""
  s.summary     = %q{Rails 3 Relevance style, with all infrastructure bits automated away.}
  s.description = %q{A Rails 3 wrapper which forces template use and includes a plethora of generators for standard Relevance bits.}

  s.rubyforge_project = "relevance_rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.bindir        = 'bin'
  s.executables   = ['relevance_rails']

  # specify any dependencies here; for example:
  s.add_runtime_dependency "rails", "~> 3.2"
  s.add_runtime_dependency 'fog', '~> 1.3.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'rspec'
end
