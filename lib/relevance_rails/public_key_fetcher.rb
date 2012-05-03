require 'tmpdir'

module RelevanceRails::PublicKeyFetcher
  def self.public_keys
    pubkeys = []
    return pubkeys unless File.exist?(user_git_url)
    git_url = File.read(user_git_url)
    return pubkeys unless git_url =~ /\/(.*)\.git/
    repo_name = $1
    Dir.mktmpdir('public_keys') { |dir|
      Dir.chdir(dir)
      `git clone -q #{git_url}`
      Dir["#{repo_name}/*.pub"].each do |pubkey|
        pubkeys += File.read(pubkey).split("\n")
      end
    }
    return pubkeys
  end

  def self.user_git_url
    File.expand_path(File.join('~','.relevance_rails','keys_git_url'))
  end

end
