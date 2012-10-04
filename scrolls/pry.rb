gem_group :development do
  gem 'pry'
end

create_file 'config/initializers/pry.rb', <<-CODE
#{app_name.camelize}::Application.configure do
  # Use Pry instead of IRB
  silence_warnings do
    begin
      require 'pry'
      IRB = Pry
    rescue LoadError
    end
  end
end
CODE

__END__

name: Pry
description: Use Pry as default console
author: jdpace

category: other
