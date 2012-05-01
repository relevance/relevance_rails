module RelevanceRails::ChefDNA
  def self.gene_splice(json, database)
    set_ruby(json)
    set_database(json, database)
  end

  private

  def self.set_database(json, database)
    if database == 'postgresql'
      db_index = json['run_list'].find_index { |e| e == 'mysql::server' || e == 'role[postgres_database]'}
      json['run_list'][db_index] = 'role[postgres_database]'
    elsif database.nil? || database == 'mysql'
      db_index = json['run_list'].find_index { |e| e == 'mysql::server' || e == 'role[postgres_database]'}
      json['run_list'][db_index] = 'mysql::server'
    end
  end

  def self.set_ruby(json)
    if RelevanceRails.ruby_version =~ /^ree-(.*)/i
      json['ruby_enterprise']['version'] = $1
      json['ruby_enterprise']['url'] = "http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-#{$1}"
      json['ruby_enterprise']['gems_version'] = rubygems_version
      update_run_list! json['run_list'], 'role[enterprise_appstack]'
    elsif RelevanceRails.ruby_version =~ /^ruby-(.*)/i
      full_version = $1
      json['ruby']['version'] = full_version
      major_version = full_version[/(\d\.\d).*/, 1]
      json['ruby']['url'] = "http://ftp.ruby-lang.org/pub/ruby/#{major_version}/ruby-#{full_version}.tar.gz"
      json['ruby']['gems_version'] = rubygems_version
      update_run_list! json['run_list'], 'role[ruby_appstack]'
    else
      raise "Your ruby is NOT SUPPORTED. Please use ree or ruby."
    end
  end

  def self.update_run_list!(run_list, val)
    appstack_index = run_list.find_index {|e| e[/^role\[.*_appstack\]$/] }
    run_list[appstack_index] = val
  end

  def self.rubygems_version
    require 'rubygems' unless defined? Gem
    Gem::VERSION
  end
end
