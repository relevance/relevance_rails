require "relevance_rails/version"
require "relevance_rails/public_key_fetcher"
require "relevance_rails/chef_dna"
require 'relevance_rails/railtie' if defined? Rails
require 'relevance_rails/generator_overrides'

module RelevanceRails
  def self.ruby_version
    @ruby_version ||= begin
      if RUBY_DESCRIPTION[/Ruby Enterprise Edition (\d{4}\.\d\d)/, 1]
        "ree-#{RUBY_VERSION}-#{$1}"
      else
        "ruby-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"
      end
    end
  end
end
