require 'relevance_rails/runner'
require 'spec_helper'

describe RelevanceRails::Runner do
  context ".start" do
    def start(*args)
      RelevanceRails::Runner.start(args)
    end

    it "with --version prints version" do
      capture_stdout { start('--version') }.chomp.should ==
        "RelevanceRails #{RelevanceRails::VERSION}"
    end

    it "new calls exec" do
      RelevanceRails::Runner.should_receive(:exec).with('rails', 'new', 'the_app', '-m',
        File.expand_path(File.dirname(__FILE__) +
                         "/../../lib/relevance_rails/relevance_rails_template.rb"))
      start('new', 'the_app')
    end
  end
end
