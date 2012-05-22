require 'spec_helper'
require 'generators/provision_config/provision_config_generator'
require 'tempfile'

describe ProvisionConfigGenerator do
  subject { ProvisionConfigGenerator.new(["name"]) }

  describe "#local_keys" do
    def write_fixture(name, contents)
      path = Tempfile.new(name).path
      subject.stub(:default_keys).and_return([path])
      File.open(path, "w") { |f| f.write(contents) }
      path
    end

    it 'has a sane default set of public keys to use' do
      defaults = %w{id_ecdsa.pub id_dsa.pub id_rsa.pub}
      defaults.map { |fname| File.expand_path("~/.ssh/#{fname}") }.each do |key|
        subject.send(:default_keys).should include key
      end
    end

    it "returns the contents of the key when it exists" do
      write_fixture('some-key.pub', 'RSA-public-key')
      subject.send(:local_keys).should == ["RSA-public-key"]
    end

    it "returns the contents of one key when multiple exist" do
      dsa = write_fixture('id_dsa.pub', "DSA-public-key")
      rsa = write_fixture('id_rsa.pub', "RSA-public-key")
      subject.stub(:default_keys).and_return([dsa, rsa])
      subject.send(:local_keys).should == ["DSA-public-key"]
    end

    it "ignores trailing newlines" do
      write_fixture('id_rsa.pub', "RSA-public-key\n\n")
      subject.send(:local_keys).should == ["RSA-public-key"]
    end

    it "ignores blank lines" do
      write_fixture('id_rsa.pub', "\n\nRSA-public-key\n\n\n")
      subject.send(:local_keys).should == ["RSA-public-key"]
    end
  end

  describe "#ssh_agent_keys" do
    it "retrieves keys from ssh agent" do
      subject.should_receive("`").with("ssh-add -L") do
        system("true")
        "my-public-key\nanother-public-key"
      end
      subject.send(:ssh_agent_keys).should == ["my-public-key", "another-public-key"]
    end

    it "ignores output from ssh-add when execution fails" do
      subject.stub("`") do
        system("false")
        # Actual message that comes back from failed call
        "The agent has no entities"
      end
      subject.send(:ssh_agent_keys).should == []
    end
  end

  describe "#fetch_keys" do
    it "returns local keys when they exist" do
      subject.stub(:local_keys).and_return(["key-from-local-file"])
      subject.stub(:ssh_agent_keys).and_return(["key-from-ssh-agent"])
      RelevanceRails::PublicKeyFetcher.stub(:public_keys).and_return([])
      subject.send(:fetch_keys).should == ["key-from-local-file"]
    end

    it "returns keys from ssh agent when local keys do NOT exist" do
      subject.stub(:local_keys).and_return([])
      subject.stub(:ssh_agent_keys).and_return(["key-from-ssh-agent"])
      RelevanceRails::PublicKeyFetcher.stub(:public_keys).and_return([])
      subject.send(:fetch_keys).should == ["key-from-ssh-agent"]
    end

    it "combines local keys with those from PublicKeyFetcher" do
      subject.stub(:local_keys).and_return(["key-from-local-file"])
      RelevanceRails::PublicKeyFetcher.stub(:public_keys).and_return(["key-from-git-repo"])
      subject.send(:fetch_keys).should == ["key-from-local-file", "key-from-git-repo"]
    end

    it "combines ssh agent keys with those from PublicKeyFetcher" do
      subject.stub(:local_keys).and_return([])
      subject.stub(:ssh_agent_keys).and_return(["key-from-ssh-agent"])
      RelevanceRails::PublicKeyFetcher.stub(:public_keys).and_return(["key-from-git-repo"])
      subject.send(:fetch_keys).should == ["key-from-ssh-agent", "key-from-git-repo"]
    end

    it "excludes duplicate keys" do
      subject.stub(:local_keys).and_return(["key-1", "key-2", "key-1"])
      RelevanceRails::PublicKeyFetcher.stub(:public_keys).and_return(["key-3", "key-2", "key-3"])
      subject.send(:fetch_keys).should == ["key-1", "key-2", "key-3"]
    end
  end

  describe "#check_authorized_keys" do
    it "aborts if no ssh-keys are found" do
      subject.stub(:fetch_keys).and_return([])
      should_abort_with(/^No SSH public keys were found!/) do
        subject.check_authorized_keys
      end
    end

    it "doesn't abort if ssh-keys are found" do
      subject.should_receive(:fetch_keys).and_return(['ssh-rsa ZZZZ'])
      expect { subject.check_authorized_keys }.to_not raise_error
    end
  end
end
