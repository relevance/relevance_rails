require "relevance_rails/version"
require "relevance_rails/public_key_fetcher"

module RelevanceRails
  def self.rvm_gemset
    @rvm_gemset ||= rvm_current.split('@')[1] || 'global'
  end

  def self.rvm_version
    @rvm_version ||= rvm_current.split('@')[0] || '1.9.3-p0'
  end

  def self.rvm_current
    @rvm_current ||= rvm_run('rvm current').chomp
  end

  def self.rvm_run(command)
    `bash -c 'source ~/.rvm/scripts/rvm > /dev/null && #{command}'`
  end
end
