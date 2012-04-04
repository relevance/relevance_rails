require "relevance_rails/version"
require "relevance_rails/public_key_fetcher"
require "relevance_rails/chef_dna"
require 'relevance_rails/railtie' if defined? Rails

module RelevanceRails
  def self.rvm_gemset
    @rvm_gemset ||= rvm_current.split('@')[1] || 'global'
  end

  def self.rvm_version
    @rvm_version ||= rvm_current.split('@')[0] || 'ruby-1.9.3-p0'
  end

  def self.rvm_current
    @rvm_current ||= rvm_exec('rvm current').chomp
  end

  # rvm_current SHOULD be in $PATH and execute ruby for the
  # correct version and gemset
  def self.rvm_run(command)
    ret = `#{rvm_current} -S #{command}`
    unless $?.success?
      abort "\n     Command '#{command}' failed with:\n#{ret}"
    end
  end
  
  def self.rvm_exec(command)
    `bash -c 'source ~/.rvm/scripts/rvm > /dev/null && #{command}'`
  end
end
