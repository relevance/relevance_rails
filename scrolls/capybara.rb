CAPYBARA_SUPPORT_FILE = <<-RUBY
require 'capybara/rails'
require 'capybara/rspec'
RUBY

gem_group :development, :test do
  gem 'capybara'
end

after_bundler do
  create_file "spec/support/capybara.rb", CAPYBARA_SUPPORT_FILE
end

__END__

name: Capybara
description: "Use the Capybara acceptance testing libraries with RSpec."
author: jdpace

requires: [rspec]
run_after: [rspec]
exclusive: acceptance_testing
category: testing
tags: [acceptance]
