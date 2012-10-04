gem_group :development, :test do
  gem 'factory_girl_rails'
end

after_bundler do
  run 'mkdir -p spec/factories'
end

__END__

name: Factory Girl
description: Use FactoryGirl
author: jdpace

exclusive: fixtures
category: testing
run_after: [devise, active_admin]
tags: [fixtures, testing]
