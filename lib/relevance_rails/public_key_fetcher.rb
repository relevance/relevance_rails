module RelevanceRails::PublicKeyFetcher
  def self.public_keys
    git_url = File.read(File.join('~','.relevance_ralis','keys_git_url'))
  end
end
