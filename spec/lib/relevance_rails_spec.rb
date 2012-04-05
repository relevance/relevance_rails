require 'spec_helper'

describe RelevanceRails do
  context '.rvm_run' do
    it 'aborts when the command fails' do
      should_abort_with(/Command '.+' failed with/) do
        subject.rvm_run('-e "exit 1"')
      end
    end

    it 'succeeds when the command passes' do
      expect { subject.rvm_run('-e "exit 0"') }.to_not raise_error
    end
  end
end
