template = File.join(File.dirname(__FILE__), "relevant_rails_template.rb")
unless ARGV.any? =~ /^-d$/ then
  ARGV.unshift template
  ARGV.unshift "-d"
end
