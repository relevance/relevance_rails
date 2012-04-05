require 'spec_helper'
require 'generators/provision_config/provision_config_generator'

describe ProvisionConfigGenerator do
  context '#create_authorized_key_data_bag' do
    subject { ProvisionConfigGenerator.new(['name']) }

    it "aborts if no ssh-keys are found" do
      subject.should_receive(:`).and_return do
        system('exit 1')
        # Actual message that comes back from failed call
        'The agent has no entities'
      end
      RelevanceRails::PublicKeyFetcher.should_receive(:public_keys).and_return([])

      should_abort_with(/^No ssh keys were found!/) do
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
