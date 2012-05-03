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
      RelevanceRails::Runner.should_receive(:exec).with(anything,
        '-S', 'rails', 'new', 'the_app', '-m',
        File.expand_path("../../../lib/relevance_rails/relevance_rails_template.rb", File.dirname(__FILE__)))
      RelevanceRails::Runner.should_receive(:install_relevance_rails)
      env = mock(:environment_name => '1.9.3@default')
      RelevanceRails::Runner.should_receive(:setup_rvm).and_return(env)
      start('new', 'the_app')
    end
  end
end
