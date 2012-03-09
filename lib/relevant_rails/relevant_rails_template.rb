git :init
append_file ".gitignore", "config/database.yml\n"
git :add => "."
git :commit => "-a -m 'Initial commit'"

