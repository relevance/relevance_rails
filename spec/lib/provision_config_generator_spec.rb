require 'spec_helper'
require 'generators/provision_config/provision_config_generator'

describe ProvisionConfigGenerator do
  context '#create_authorized_key_data_bag' do
    subject { ProvisionConfigGenerator.new(['name']) }

    it "aborts if no ssh-keys are found" do
      subject.should_receive(:fetch_keys).and_return([])
      msg = "No ssh keys were found! Check ssh-add -L and your keys_git_url config."
      should_abort_with(msg) do
        subject.create_authorized_key_data_bag
      end
    end

    it "doesn't abort if ssh-keys are found" do
      subject.should_receive(:fetch_keys).and_return(['ssh-rsa ZZZZ'])
      subject.should_receive(:template)
      expect { subject.create_authorized_key_data_bag }.to_not raise_error
    end
  end
end
