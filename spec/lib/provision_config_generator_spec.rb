require 'spec_helper'
require 'generators/provision_config/provision_config_generator'

describe ProvisionConfigGenerator do
  context '#create_authorized_key_data_bag' do
    subject { ProvisionConfigGenerator.new(['name']) }
    it "aborts if no ssh-keys are found" do
      subject.should_receive(:fetch_keys).and_return([])
      expect do
        subject.create_authorized_key_data_bag
      end.to raise_error SystemExit,
        "No ssh keys were found! Check ssh-add -L and your keys_git_url config."
    end
  end
end
