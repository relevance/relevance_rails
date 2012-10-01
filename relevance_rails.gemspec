# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relevance_rails/version'

Gem::Specification.new do |gem|
  gem.name          = "relevance_rails"
  gem.version       = RelevanceRails::VERSION
  gem.authors       = ["Relevance"]
  gem.email         = ["opensource@thinkrelevance.com"]
  gem.description   = %q{Opinionated Rails app generator built on Appscrolls}
  gem.summary       = %q{Opinionated Rails app generator built on Appscrolls}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'appscrolls', '~> 0.8.4'
  gem.add_dependency 'gli', '~> 2.0.0'
  gem.add_dependency 'highline', '~> 1.6.0'
end
