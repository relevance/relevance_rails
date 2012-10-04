DB_SAMPLE_RAKEFILE = <<-RUBY
namespace :db do
  desc "Populate the database with sample data"
  task :sample => :environment do
    Rails.application.config.paths.add 'db/samples', :with => 'db/samples.rb'
    load 'db/samples.rb'
  end
  task :populate => [:seed, :sample]
end
RUBY

DB_SAMPLE_FILE = <<-RUBY
# This file should contain any records needed to be crated as sample data. Sample data is any data
# you want to bootstrap your application with in order to make it demo worthy. Seed data is necessary
# for the application to function initially (e.g Cities, known datasets, Initial Admin user).
# The data can then be loaded with the rake db:sample (or created alongside the db with db:setup).
#
# Examples:
#
#   quentin = User.create :name => 'Quentin'
RUBY

rakefile 'db/sample.rake', DB_SAMPLE_RAKEFILE
create_file 'db/samples.rb', DB_SAMPLE_FILE

__END__

name: SampleData
description: Creates a rake task for the purposes of loading sample data
author: jdpace
category: other
