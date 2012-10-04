KNOWN_GUARD_SCROLLS = %w[cucumber haml less livereload passenger puma redis resque rspec spork unicorn]

RBCONFIG_INCLUDE = <<-RUBY
require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']

RUBY

def scroll_specific_guard_gems
  gems = []
  gems << 'guard-test' if scrolls.include? 'test_unit'
  KNOWN_GUARD_SCROLLS.each do |scroll|
    gems << "guard-#{scroll}" if scrolls.include? scroll
  end

  gems.map { |gem| "  gem '#{gem}'" }.join("\n")
end

GUARD_GEMFILE_CONFIG = <<-RUBY

group :development do
  gem 'guard-bundler'
#{ scroll_specific_guard_gems }

  # Load correct OS specific notification libraries for Guard
  guard_notifications = #{config['guard_notifications'].inspect}
  case HOST_OS
  when /darwin/i
    gem 'rb-fsevent'
    gem 'ruby_gntp' if guard_notifications
  when /linux/i
    gem 'libnotify'
    gem 'rb-inotify'
  when /mswin|windows/i
    gem 'rb-fchange'
    gem 'win32console'
    gem 'rb-notifu' if guard_notifications
  end
end
RUBY

prepend_file 'Gemfile', RBCONFIG_INCLUDE
append_file 'Gemfile', GUARD_GEMFILE_CONFIG

after_bundler do
  run "bundle exec guard init"
end

__END__

name: Guard
description: Watches for changes in files and performs relevant actions
author: jdpace
website: https://github.com/guard/guard
category: other

config:
  - guard_notifications:
      type: boolean
      prompt: "Enable desktop Guard/Growl notifications?"
