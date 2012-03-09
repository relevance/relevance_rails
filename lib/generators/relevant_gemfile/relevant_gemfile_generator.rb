class RelevantGemfileGenerator < Rails::Generators::Base

  desc "This generator creates a Gemfile with the standard Relevance gems."

  source_root File.expand_path("../templates", __FILE__)

  def copy_gemfile
    copy_file "Gemfile", "Gemfile"
  end
end
