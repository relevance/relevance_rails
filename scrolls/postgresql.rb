gsub_file "config/database.yml", /username: .*/, "username: #{config['pg_username']}"
gsub_file "config/database.yml", /password: .*/, "password: #{config['pg_password']}"

after_bundler do
  rake "db:create:all"
end

__END__

name: PostgreSQL
description: Use PostgreSQL for dev & production database
author: jdpace

exclusive: orm
category: persistence

args: [--database=postgresql]

config:
  - pg_username:
      type: string
      prompt: "Local development PostgreSQL username:"
  - pg_password:
      type: string
      prompt: "Local development PostgreSQL password:"
