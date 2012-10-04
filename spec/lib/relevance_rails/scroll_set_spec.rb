require 'spec_helper'

describe RelevanceRails::ScrollSet do

  describe '.new' do
    let(:scrolls) { %w(active_admin git haml postgresql) }
    subject { RelevanceRails::ScrollSet.new scrolls }

    it { should be_instance_of RelevanceRails::ScrollSet }
    its(:count) { should == 4 }
    it 'converts scrolls to their class versions' do
      scroll_classes = scrolls.map { |s| AppScrollsScrolls::Scrolls[s] }
      subject.should include(*scroll_classes)
    end
  end

  describe '#union_minus_intersection!' do
    let(:scroll_set) { RelevanceRails::ScrollSet.new %w(active_admin postgresql) }

    it 'adds new scrolls' do
      scroll_set.union_minus_intersection! %w(git haml)
      scroll_set.should include(AppScrollsScrolls::Scrolls['git'], AppScrollsScrolls::Scrolls['haml'])
    end

    it 'removes scrolls that are already present' do
      scroll_set.union_minus_intersection! %w(postgresql)
      scroll_set.should_not include(AppScrollsScrolls::Scrolls['postgresql'])
    end

    it 'adds and removes scrolls' do
      scroll_set.union_minus_intersection! %w(postgresql mysql)
      scroll_set.should include(AppScrollsScrolls::Scrolls['mysql'])
      scroll_set.should_not include(AppScrollsScrolls::Scrolls['postgresql'])
    end
  end

  describe '#build_template' do
    let(:scroll_set) { RelevanceRails::ScrollSet.new %w(active_admin postgresql) }
    subject { scroll_set.build_template }

    it { should be_instance_of AppScrollsScrolls::Template }
    its(:scrolls) { should include(*scroll_set.scrolls) }
  end

  describe '#resolved' do
    let(:scroll_set) { RelevanceRails::ScrollSet.new %w(active_admin github postgresql) }
    subject { scroll_set.resolved }

    it { should be_instance_of RelevanceRails::ScrollSet }
    it { should include(*scroll_set.scrolls) }
    it { should include(AppScrollsScrolls::Scrolls['git']) } # git is a dependency of github
  end

  describe '#run' do
    let(:scroll_set) { RelevanceRails::ScrollSet.new %w(active_admin postgresql) }
    let(:template_file) do
      tempfile = double('tempfile')
      %w(write flush path unlink).each { |method| tempfile.stub(method) }
      tempfile
    end

    before do
      Tempfile.stub(:new).and_return(template_file)
      scroll_set.stub(:system)
    end

    it 'creates the template as a tempfile' do
      template_file.should_receive(:write).with(scroll_set.build_template.compile).ordered
      template_file.should_receive(:flush).ordered
      scroll_set.run 'foo_bar'
    end

    it 'runs rails app generator with the specified options' do
      template_file.stub(:path).and_return '/tmp/foo_bar_template'
      scroll_set.should_receive(:system).with('rails new foo_bar -m /tmp/foo_bar_template --database=postgresql')
      scroll_set.run 'foo_bar'
    end
  end

end
