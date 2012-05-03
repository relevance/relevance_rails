require 'spec_helper'
require 'fileutils'
require 'relevance_rails/provision'

describe "Elzar recipes", :ci => true do
  let(:rails_app) { 'elzar_nightly_app' }
  let(:server_name) { "Elzar Nightly Build Testing - #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}" }
  let(:database) { ENV['CI_DATABASE'] || 'mysql' }
  let(:database_cmd) { { 'mysql' => 'mysql', 'postgresql' => 'psql'}[database] }
  let(:ruby_version) { ENV['CI_RUBY_VERSION'] || 'ruby-1.9.3-p125' }
  let(:ruby_bin_path) {
    ruby_version.start_with?('ree-') ? '/opt/ruby-enterprise/bin' : '/opt/relevance-ruby/bin'
  }

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
    @current_gemset ||= 'relevance_rails'
  end

  def rake(cmd)
    sh "bundle exec rake #{cmd}"
  end

  def create_new_app
    rake 'install --trace'
    FileUtils.rm_rf(rails_app)
    rvm "--force gemset delete #{rails_app}"
    sh "relevance_rails new #{rails_app} --database=#{database} --relevance-dev"
  end

  def ssh(cmd)
    server = RelevanceRails::Provision.current_server
    server.username = 'relevance'
    job = nil
    capture_stdout { job = server.ssh(cmd).first }
    job
  end

  def command_succeeds(cmd)
    ssh(cmd).status.should == 0
  end

  before(:all) do
    create_new_app
    Dir.chdir rails_app
    # actually switches the gemset
    @current_gemset = rails_app
    rake %[provision:ec2 NAME="#{server_name}" --trace]
  end

  it "installs the right ruby" do
    job = ssh "#{ruby_bin_path}/ruby -v"
    if ruby_version.start_with?('ree-')
      job.stdout.include?("Ruby Enterprise Edition").should be_true
    else
      version_number = ruby_version.sub(/^ruby/, '').tr('-', '')
      job.stdout.start_with?("ruby #{version_number}").should be_true
    end
  end

  it "installs the correct database" do
    command_succeeds("#{database_cmd} --version")
  end

  it "creates a deploy user" do
    command_succeeds("ls /home/deploy")
  end

  it "creates nginx and configures it" do
    # TODO: get nginx version from elzar
    command_succeeds "/opt/nginx-1.0.10/sbin/nginx -h"
    command_succeeds "ls /etc/nginx/nginx.conf"
    command_succeeds "ls /etc/init.d/nginx"
    command_succeeds "ls /etc/nginx/sites-enabled/#{rails_app}"
  end

  it "installs passenger gem and configures it" do
    command_succeeds "#{ruby_bin_path}/gem list passenger$ |grep passenger -q"
    command_succeeds "ls /etc/nginx/conf.d/passenger.conf"
    command_succeeds %[grep -q "passenger_ruby #{ruby_bin_path}/ruby;" /etc/nginx/conf.d/passenger.conf]
  end
end
