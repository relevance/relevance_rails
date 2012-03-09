# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "relevant_rails/version"

Gem::Specification.new do |s|
  s.name        = "relevant_rails"
  s.version     = RelevantRails::VERSION
  s.authors     = ["Alex Redington"]
  s.email       = ["alex.redington@thinkrelevance.com"]
  s.homepage    = ""
  s.summary     = %q{Rails 3 Relevance style, with all infrastructure bits automated away.}
  s.description = %q{A Rails 3 wrapper which forces template use and includes a plethora of generators for standard Relevance bits.}

  s.rubyforge_project = "relevant_rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.bindir        = 'bin'
  s.executables   = ['relevant_rails']

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "rails", "~> 3.1"
end
