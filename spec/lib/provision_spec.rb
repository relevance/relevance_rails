require 'spec_helper'
require 'relevance_rails/provision'

describe RelevanceRails::Provision do
  def job(options={})
    options = {:stdout => '', :stderr => '', :status => 0}.update options
    mock(options)
  end

  describe '.run_commands' do
    it "fails fast if a command fails" do
      server = mock(:ssh => [job(:status => 1, :command => 'exit 1', :stderr => 'FAIL WHALE')])
      capture_stdout do
        expect do
          RelevanceRails::Provision.run_commands server
        end.to raise_error SystemExit
      end.should =~ /STDERR: FAIL WHALE/
    end
  end

  describe '.wait_for_ssh' do

    let(:server) { mock("server") }

    before do
      server.should_receive(:wait_for).ordered.and_return(true)
    end

    it 'retries if the first attempt fails' do
      server.should_receive(:ssh).ordered.and_raise(Errno::ECONNREFUSED)
      server.should_receive(:ssh).ordered.and_return([job(:command => 'echo')])
      RelevanceRails::Provision.should_receive(:sleep).twice.with(10).and_return(10)
      expect do
        capture_stdout { RelevanceRails::Provision.wait_for_ssh(server) }
      end.to_not raise_error
    end

    it 'retries up to five times, then fails' do
      server.should_receive(:ssh).ordered.exactly(5).times.and_raise(Errno::ECONNREFUSED)
      RelevanceRails::Provision.should_receive(:sleep).exactly(5).times.with(10).and_return(10)
      expect do
        capture_stdout { RelevanceRails::Provision.wait_for_ssh(server) }
      end.to raise_error SystemExit
    end
  end

  describe '.apt_installs' do
    it 'retries if the first attempt fails' do
      server = mock("server")
      server.should_receive(:ssh).ordered.with('sudo apt-get update').and_return([job(:command => 'sudo apt-get update')])
      server.should_receive(:ssh).ordered.with('sudo apt-get -y install ruby').and_return([job(:status => 1, :command => 'sudo apt-get -y install ruby')])
      server.should_receive(:ssh).ordered.with('sudo apt-get update').and_return([job(:command => 'sudo apt-get update')])
      server.should_receive(:ssh).ordered.with('sudo apt-get -y install ruby').and_return([job(:command => 'sudo apt-get -y install ruby')])
      server.should_receive(:ssh).ordered.with('sudo apt-get -y install rubygems1.8').and_return([job(:command => 'sudo apt-get -y install rubygems1.8')])
      expect do
        capture_stdout { RelevanceRails::Provision.apt_installs(server) }
      end.to_not raise_error
    end

    it 'tries five times and then aborts' do
      server = mock("server")
      server.should_receive(:ssh).exactly(5).with('sudo apt-get update').and_return([job(:status => 1, :command => 'sudo apt-get update')])
      expect do
        capture_stdout { RelevanceRails::Provision.apt_installs(server) }
      end.to raise_error SystemExit
    end
  end
end
