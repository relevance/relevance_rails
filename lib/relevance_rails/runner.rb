require 'relevance_rails'

module RelevanceRails
  class Runner
    def self.start(argv=ARGV)
      if argv.delete '--version'
        puts "RelevanceRails #{RelevanceRails::VERSION}"
      else
        add_default_options! argv
        exec 'rails', *argv
      end
    end

    private

    def self.add_default_options!(argv)
      unless argv.any? =~ /^-d$/
        template = File.join(File.dirname(__FILE__), "relevance_rails_template.rb")
        argv << '-m'
        argv << template
      end
    end
  end
end
