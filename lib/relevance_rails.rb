require "relevance_rails/version"
require "relevance_rails/public_key_fetcher"
require "relevance_rails/chef_dna"
require 'relevance_rails/railtie' if defined? Rails
require 'relevance_rails/generator_overrides'

module RelevanceRails
  class << self
    attr_accessor :rvm_exists
  end

  def self.ruby_version
    @ruby_version ||= rvm_exists ? RVM::Environment.current_ruby_string :
      "ruby-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"
  end
end
