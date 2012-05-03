require 'spec_helper'
require 'fileutils'
require 'fakefs/spec_helpers'
require 'generators/provision_config/provision_config_generator'

describe ProvisionConfigGenerator do
  subject { ProvisionConfigGenerator.new(["name"]) }

  describe "#local_keys" do
    include FakeFS::SpecHelpers

    def write_fixture(path, contents)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, "w") { |f| f.write(contents) }
    end

    it "returns the contents of id_rsa.pub when it exists" do
      write_fixture(File.expand_path("~/.ssh/id_rsa.pub"), "RSA-public-key")
      subject.send(:local_keys).should == ["RSA-public-key"]
    end

    it "returns the contents of id_dsa.pub when it exists" do
      write_fixture(File.expand_path("~/.ssh/id_dsa.pub"), "DSA-public-key")
      subject.send(:local_keys).should == ["DSA-public-key"]
    end

    it "returns the contents of id_ecdsa.pub when it exists" do
      write_fixture(File.expand_path("~/.ssh/id_ecdsa.pub"), "ECDSA-public-key")
      subject.send(:local_keys).should == ["ECDSA-public-key"]
    end

    it "returns the contents of id_dsa.pub when both id_dsa.pub and id_rsa.pub exist" do
      write_fixture(File.expand_path("~/.ssh/id_dsa.pub"), "DSA-public-key")
      write_fixture(File.expand_path("~/.ssh/id_rsa.pub"), "RSA-public-key")
      subject.send(:local_keys).should == ["DSA-public-key"]
    end

    it "ignores trailing newlines" do
      write_fixture(File.expand_path("~/.ssh/id_rsa.pub"), "RSA-public-key\n\n")
      subject.send(:local_keys).should == ["RSA-public-key"]
    end

    it "ignores blank lines" do
      write_fixture(File.expand_path("~/.ssh/id_rsa.pub"), "\n\nRSA-public-key\n\n\n")
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
