template = File.join(File.dirname(__FILE__), "relevance_rails_template.rb")
unless ARGV.any? =~ /^-d$/ then
  ARGV << '-m'
  ARGV << template
end
