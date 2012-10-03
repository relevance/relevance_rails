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
        say "RelevanceRails Application Generator"
        say "====================================\n\n"

        scrolls = build_scroll_set

        if options[:dry_run]
          display_template scrolls
        else
          scrolls.run app_name
        end
      end

      private

      def build_scroll_set
        initial_set = RelevanceRails::OpinionatedStacks::Default
        RelevanceRails::ScrollSet.new(initial_set).tap do |scrolls|
          until user_confirmed_scrolls?(scrolls)
            scrolls.union_minus_intersection!(ask_user_for_scrolls)
          end
        end
      end

      def user_confirmed_scrolls?(scrolls)
        say "The generator will run the following scrolls:"
        resolved_scrolls = scrolls.resolved.map do |resolved_scroll|
          color = scrolls.include?(resolved_scroll) ? 'green' : 'yellow'
          "<%= color(#{resolved_scroll.key.inspect}, :#{color}) %%>"
        end

        say "<%= list(#{resolved_scrolls.inspect}, :uneven_columns_down) %>\n"
        agree "Is this correct? (yes/no)"
      end

      def ask_user_for_scrolls
        ask("What scrolls would you like to add/remove from the list?", String) do |question|
          question.gather = ""
        end
      end

      def display_template(scrolls)
        say "Compiled Template"
        say "=" * 40
        say scrolls.build_template.compile
      end

    end
  end
end
