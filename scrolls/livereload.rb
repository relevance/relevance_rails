gem_group :development do
  gem 'rack-livereload'
  gem 'yajl-ruby'
end

application nil, :env => "development" do
  "config.middleware.insert_before(Rack::Lock, Rack::LiveReload)"
end

__END__

name: Livereload
description: Automatically reloads browser when files change
author: jdpace
category: other
