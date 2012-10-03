require 'pathname'
require 'appscrolls'
require 'relevance_rails/ext/appscrolls/template'
require 'relevance_rails/version'
require 'relevance_rails/opinionated_stacks'
require 'relevance_rails/scrolls'
require 'relevance_rails/scroll_set'

module RelevanceRails
  def self.root
    @root ||= Pathname.new File.expand_path('../..', __FILE__)
  end
end

RelevanceRails::Scrolls.load_scrolls
