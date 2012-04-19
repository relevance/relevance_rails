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

  describe '.wait_for_ssh' do
    it 'retries up to 5 times, then fails' do
      server = mock("server")
      server.should_receive(:wait_for).ordered.and_return(true)
      server.should_receive(:ssh).ordered.and_raise(Errno::ECONNREFUSED)
      server.should_receive(:ssh).ordered.and_return([mock(:status => 0, :stdout => '', :stderr => '', :command => 'echo')])
      STDOUT.should_receive(:puts).with("Waiting for ssh connectivity...")
      STDOUT.should_receive(:puts).with("Connecting to Amazon refused. Retrying...")
      STDOUT.should_receive(:puts).with("Server up and listening for SSH!")
      RelevanceRails::Provision.should_receive(:sleep).twice.with(10).and_return(10)
      expect do
        RelevanceRails::Provision.wait_for_ssh(server)
      end.to_not raise_error
    end
  end

  describe '.apt_installs' do
    it 'retries twice, then fails' do
      server = mock("server")
      server.should_receive(:ssh).ordered.with('sudo apt-get update').and_return([mock(:status => 0, :stdout => 'waha! no ruby for you...', :stderr => '', :command => 'sudo apt-get update')])
      server.should_receive(:ssh).ordered.with('sudo apt-get -y install ruby').and_return([mock(:status => 1, :stdout => '', :stderr => 'no ruby candidate, I hate you', :command => 'sudo apt-get -y install ruby')])
      server.should_receive(:ssh).ordered.with('sudo apt-get update').and_return([mock(:status => 0, :stdout => 'i know how to do ruby now', :stderr => '', :command => 'sudo apt-get update')])
      server.should_receive(:ssh).ordered.with('sudo apt-get -y install ruby').and_return([mock(:status => 0, :stdout => 'ruby installed!', :stderr => '', :command => 'sudo apt-get -y install ruby')])
      server.should_receive(:ssh).ordered.with('sudo apt-get -y install rubygems1.8').and_return([mock(:status => 0, :stdout => 'rubygems installed!', :stderr => '', :command => 'sudo apt-get -y install rubygems1.8')])
      STDOUT.should_receive(:puts).any_number_of_times
      expect do
        RelevanceRails::Provision.apt_installs(server)
      end.to_not raise_error
    end
  end
end
