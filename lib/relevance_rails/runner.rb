require 'relevance_rails'

module RelevanceRails
  class Runner
    def self.start(argv=ARGV)
      if argv.empty? || (argv[0] == '--help') || (argv[0] == '-h')
        print_help
      elsif argv.delete('--version')
        puts "RelevanceRails #{RelevanceRails::VERSION}"
      elsif argv[0] == 'new'
        add_default_options! argv
        #if ENV['rvm_path'].nil? || ENV['NO_RVM']
          exec 'rails', *argv
        #else
        #  app_name = argv[1]
        #  env = setup_rvm(app_name)

        #  new_rvm_string = "#{env.environment_name.split('@')[0]}@#{app_name}"
        #  install_relevance_rails argv, new_rvm_string, env.environment_name
        #  exec new_rvm_string,'-S','rails', *argv
        #end
      end
    end

    private

    def self.print_help
      puts <<-STR
Usage: relevance_rails new APP [OPTIONS]

Options:

-d, --database <database>: Generate dependencies, configuration, and deployments
                           for database, only supports mysql (default) and
                           postgresql

When invoked in an RVM shell, the new project and newly provisioned servers will
inherit the current ruby. The new project will get its own gemset.

When invoked in other contexts, newly provisioned servers will attempt to
install a ruby which matches the ruby executing the relevance_rails process.
STR
    end

    def self.setup_rvm(app_name)
      rvm_version = Gem::Version.new(`rvm --version`[/rvm (\d\.\d+\.\d+)/, 1].to_s)

      if rvm_version < Gem::Version.new('1.10.2')
        abort "Rvm version 1.10.2 or greater is required. Run 'rvm get stable'"
      end

      if rvm_version < Gem::Version.new('1.12.0')
        # RVM's ruby drivers were factored out into a gem
        # in 1.12.0, so you don't use this trick anymore.
        $LOAD_PATH.unshift "#{ENV['rvm_path']}/lib"
      end
      require 'rvm'
      env = RVM::Environment.current
      env.gemset_create(app_name)
      env
    end

    def self.install_relevance_rails(argv, new_rvm_string, current_gemset)
      child_env = RVM::Environment.new(new_rvm_string)
      puts "Installing relevance_rails into the app's gemset..."

      result = if argv.delete('--relevance-dev')
        gem_dir = "#{ENV['rvm_path']}/gems/#{current_gemset}/cache"
        require 'elzar'
        child_env.run('gem', 'install', "#{gem_dir}/elzar-#{Elzar::VERSION}.gem")
        child_env.run('gem', 'install', "#{gem_dir}/relevance_rails-#{RelevanceRails::VERSION}.gem")
      else
        child_env.run('gem', 'install', 'relevance_rails', '-v', RelevanceRails::VERSION)
      end
      if result.exit_status != 0
        abort "Unable to install relevance_rails into the new gemset. " +
          "\nExit code: #{result.exit_status}" +
          "\nFailed with:\n#{result.stderr}"
      end
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
