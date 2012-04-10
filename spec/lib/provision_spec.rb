require 'spec_helper'
require 'relevance_rails/provision'

describe RelevanceRails::Provision do
  describe '.run_commands' do
    it "fails fast if a command fails" do
      job = mock(:status => 1, :stdout => '', :stderr => 'FAIL WHALE', :command => 'exit 1')
      server = mock(:ssh => [job])
      capture_stdout do
        expect do
          RelevanceRails::Provision.run_commands server
        end.to raise_error SystemExit
      end.should =~ /STDERR: FAIL WHALE/
    end
  end
end
