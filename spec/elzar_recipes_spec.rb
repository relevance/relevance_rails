require 'spec_helper'
require 'fileutils'
require 'relevance_rails/provision'

describe "Elzar recipes" do
  let(:rails_app) { 'elzar_nightly_app' }
  let(:server_name) { "Elzar Nightly Build Testing - #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}" }
  let(:database) { ENV['CI_DATABASE'] || 'mysql' }
  let(:database_cmd) { { 'mysql' => 'mysql', 'postgresql' => 'psql'}[database] }
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

  def ssh(cmd)
    server = RelevanceRails::Provision.current_server
    server.username = 'relevance'
    server.ssh(cmd).first
  end

  def command_succeeds(cmd)
    job = ssh cmd
    job.status.should == 0
  end

  before(:all) do
    create_new_app
    Dir.chdir rails_app
    # actually switches the gemset
    @current_gemset = rails_app
    rake %[provision:ec2 NAME="#{server_name}" --trace]
  end

  it "installs the right ruby" do
    job = ssh('/opt/relevance-ruby/bin/ruby -v')
    version_number = ruby_version.sub(/^ruby/, '').tr('-', '')
    job.stdout.should be_start_with("ruby #{version_number}")
  end

  it "installs the correct database" do
    command_succeeds("#{database_cmd} --version")
  end

  it "creates a deploy user" do
    command_succeeds("ls /home/deploy")
  end

  # TODO: get nginx version from elzar
  it "creates nginx" do
    command_succeeds("/opt/nginx-1.0.10/sbin/nginx -h")
  end

  it "creates a passenger config" do
    command_succeeds("ls /etc/nginx/conf.d/passenger.conf")
  end
end
