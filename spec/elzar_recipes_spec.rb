require 'spec_helper'
require 'fileutils'

describe "Elzar recipes" do
  let(:rails_app) { 'elzar_nightly_app' }
  let(:server_name) { "Elzar Nightly Build Testing - #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}" }
  let(:database) { ENV['CI_DATABASE'] || 'mysql' }
  let(:ruby_version) { ENV['CI_RUBY_VERSION'] || 'ruby-1.9.3-p125' }

  # wrapper around system
  def shell(cmd)
    puts "Executing #{cmd}..."
    system(cmd)
    abort "Command '#{cmd}' failed" unless $?.success?
  end

  def rvm(cmd)
    shell %[bash -c "source ~/.rvm/scripts/rvm ; rvm #{cmd}"]
  end

  def sh(cmd)
    shell "#{ruby_version}@#{current_gemset} -S #{cmd}"
  end

  def current_gemset
    @current_gemset ||= 'relevance_spec2'
  end

  def rake(cmd)
    sh "bundle exec rake #{cmd}"
  end

  def create_new_app
    rvm "use '#{ruby_version}@#{current_gemset}'"
    sh 'gem install bundler'
    sh 'bundle install'
    rake 'install --trace'
    FileUtils.rm_rf(rails_app)
    rvm "--force gemset delete #{rails_app}"
    sh "relevance_rails new #{rails_app} --database=#{database} --relevance-dev"
  end

  before(:all) do
    create_new_app
    Dir.chdir rails_app
    # actually switches the gemset
    @current_gemset = rails_app
    rake %[provision:ec2 NAME="#{server_name}" --trace]
  end

  it "can handle the truth" do
    true.should == true
  end
end
