class RelevantGemfileGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def copy_gemfile
    copy_file "Gemfile", "Gemfile"
  end
end
