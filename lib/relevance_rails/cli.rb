require 'relevance_rails'
require 'highline/import'

module RelevanceRails
  module Cli
    class MissingArgumentsError < StandardError
      def initialize(cmd, arguments)
        super "Required arguments missing (#{arguments.join(', ')})." \
          " Run `relevance_rails help #{cmd}` for more information."
      end
    end

    class Runner
      def self.run(*args)
        runner = new(*args)
        runner.require_arguments!
        runner.run
      end

      def self.required_argument(*arg_names)
        @required_arguments ||= []
        @required_arguments += arg_names
      end

      def self.required_arguments
        @required_arguments || []
      end

      def require_arguments!
        missing_arguments = self.class.required_arguments.select do |arg|
          arg_value = self.instance_variable_get(:"@#{arg}")
          arg_value.to_s.strip.empty?
        end

        raise MissingArgumentsError.new(cmd, missing_arguments) unless missing_arguments.empty?
      end

      private

      def notify(msg)
        # TODO chop off only initial indentation level
        puts msg.gsub(/^\s+/,'')
      end

      def cmd
        self.class.name.split('::').last.downcase
      end
    end

    class New < Runner

      attr_reader :app_name

      required_argument :app_name

      def initialize(app_name, options)
        @app_name = app_name
      end

      def run
        # TODO
        puts "Generating new app: #{app_name}"
      end

    end
  end
end
