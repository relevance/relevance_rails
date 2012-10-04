gem 'haml', '>= 3.0.0'
gem 'haml-rails'

if config['convert_erb']
  gem_group :development do
    # Needed for html2haml parser
    gem 'hpricot'
    gem 'ruby_parser'
  end
end

after_bundler do
  if config['convert_erb']
    Dir['app/views/**/*.erb'].each do |path_to_erb|
      say_wizard "Converting ERB to Haml: #{path_to_erb}"
      template_directory = File.dirname path_to_erb
      template_name = File.basename path_to_erb, '.erb'
      run %Q{bundle exec html2haml "#{path_to_erb}" > "#{template_directory}/#{template_name}.haml"}
      remove_file path_to_erb
    end
  end
end

__END__

name: HAML
description: "Utilize HAML for templating."
author: jdpace

category: templating
exclusive: templating

config:
  - convert_erb:
      type: boolean
      prompt: "Would you like to attempt to convert existing ERB files to Haml?"
