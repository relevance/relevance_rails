require 'spec_helper' 

describe RelevanceRails do
  context '.rvm_run' do
    it 'aborts when the command fails' do
      silence do
        expect { subject.rvm_run('-e "exit 1"') }.to raise_error(SystemExit, /Command '.+' failed with/)
      end
    end

    it 'succeeds when the command passes' do
      expect { subject.rvm_run('-e "exit 0"') }.to_not raise_error
    end
  end
end
