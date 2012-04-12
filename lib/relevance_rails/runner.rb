require 'relevance_rails'

module RelevanceRails
  class Runner
    def self.start(argv=ARGV)
      if argv.delete '--version'
        puts "RelevanceRails #{RelevanceRails::VERSION}"
      elsif argv[0] == 'new'
        add_default_options! argv
        if ENV['rvm_path'].nil?
          exec 'rails', *argv
        else
          app_name = argv[1]
          env = setup_rvm app_name

          new_rvm_string = "#{env.environment_name.split('@')[0]}@#{app_name}"
          install_relevance_rails argv, new_rvm_string, env.environment_name
          exec new_rvm_string,'-S','rails', *argv
        end
      end
    end

    private

    def self.setup_rvm(app_name)
      $LOAD_PATH.unshift "#{ENV['rvm_path']}/lib"
      require 'rvm'

      env = RVM::Environment.current
      env.gemset_create(app_name)
      env
    end

    def self.install_relevance_rails(argv, new_rvm_string, current_gemset)
      child_env = RVM::Environment.new(new_rvm_string)
      puts "Installing relevance_rails into the app's gemset..."

      result = if argv.delete '--relevance-dev'
        rubygem = "#{ENV['rvm_path']}/gems/#{current_gemset}/cache/relevance_rails-#{RelevanceRails::VERSION}.gem"
        child_env.run('gem', 'install', rubygem)
      else
        child_env.run('gem', 'install', 'relevance_rails', '-v', RelevanceRails::VERSION)
      end
      abort "Unable to install relevance_rails into the new gemset" if result.exit_status != 0
    end

    def self.add_default_options!(argv)
      unless argv.any? =~ /^-d$/
        template = File.join(File.dirname(__FILE__), "relevance_rails_template.rb")
        argv << '-m'
        argv << template
      end
    end
  end
end
