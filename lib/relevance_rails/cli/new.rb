require 'tempfile'

module RelevanceRails
  module Cli
    class New < Runner

      attr_reader :app_name, :options

      required_argument :app_name

      def initialize(app_name, options)
        @app_name = app_name
        @options = options
      end

      def run
        stack_scrolls = RelevanceRails::OpinionatedStacks::Default
        user_specified_scrolls = ask_for_user_scrolls(stack_scrolls)
        scrolls = RelevanceRails::Scrolls.union_minus_intersection(stack_scrolls, user_specified_scrolls)

        template = AppScrollsScrolls::Template.new(scrolls)
        announce_resolved_scolls(template)

        compile_and_run_template(template, options[:dry_run])
      end

      def ask_for_user_scrolls(starting_scrolls)
        say "RelevanceRails Application Generator"
        say "====================================\n\n"
        say "Starting with the following list of opinionated scrolls:"
        say "<%= color(list(#{starting_scrolls.inspect}, :uneven_columns_down), :green) %>\n"
        ask("What scrolls would you like to add/remove from the list?", String) do |question|
          question.gather = ""
        end
      end

      def announce_resolved_scolls(template)
        say "\nGenerating an app with the following scrolls:"
        resolved_scrolls = template.resolve_scrolls.map do |scroll|
          color = template.scrolls.include?(scroll) ? 'green' : 'yellow'
          "<%= color(#{scroll.key.inspect}, :#{color}) %%>"
        end

        say "<%= list(#{resolved_scrolls.inspect}, :uneven_columns_down) %>\n"
      end

      def compile_and_run_template(template, display_only=false)
        template_file = Tempfile.new('relevance-rails-template')
        template_file.write template.compile
        template_file.flush

        if display_only
          puts "Compiled Template"
          puts "=" * 40
          puts template_file.rewind && template_file.read
        else
          system "rails new #{app_name} -m #{template_file.path} #{template.args.join(' ')}"
        end
      ensure
        template_file.unlink
      end
    end
  end
end
