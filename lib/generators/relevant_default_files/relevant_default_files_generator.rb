class RelevantDefaultFilesGenerator < Rails::Generators::Base

  desc "This generator creates a number of default Rails files."

  source_root File.expand_path("../templates", __FILE__)

  def create_readme_markdown
    create_file "README.markdown", <<-README
# #{app_name}

## Getting Started

gem install bundler
# TODO other setup commands here
    README
  end

  def create_application_layout
    create_file 'app/views/layouts/application.html.haml', <<LAYOUT
!!!
%html
  %head
    %title #{app_name}
  = stylesheet_link_tag :application
  = javascript_include_tag :application
  = csrf_meta_tag
  %body
    = yield
LAYOUT
  end

  def create_rvmrc
    create_file ".rvmrc", "rvm ree-1.8.7-2012.02@#{app_name}"
  end

end
