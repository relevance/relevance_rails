require 'relevance_rails'

module RelevanceRails
  class Runner
    def self.start(argv=ARGV)
      if argv.delete '--version'
        puts "RelevanceRails #{RelevanceRails::VERSION}"
      else
        add_default_options! argv
        if ENV['rvm_path'].nil?
          exec 'rails', *argv
        else
          $LOAD_PATH.unshift "#{ENV['rvm_path']}/lib"
          require 'rvm'
          RelevanceRails.rvm_exists = true

          env = RVM::Environment.current
          env.gemset_create(argv[1])

          exec "#{RVM::Environment.current_ruby_string}@#{argv[1]}",'-S','rails', *argv
        end
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
