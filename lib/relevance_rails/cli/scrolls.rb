module RelevanceRails
  module Cli
    class Scrolls < Runner

      def initialize(options)
        @options = options
      end

      def run
        AppScrollsScrolls::Scrolls.categories.each do |category|
          say "<%= color '#{category}', :magenta, :bold %>"
          say "<%= color '#{"-" * category.length}', :magenta, :bold %>"
          display_scrolls AppScrollsScrolls::Scrolls.for(category)
        end
      end

      def display_scrolls(scrolls)
        min_padding = 4
        max_scroll_width = AppScrollsScrolls::Scrolls.list.map(&:length).max

        scrolls_with_descriptions = scrolls.map do |s|
          name_column = s + (' ' * (max_scroll_width + min_padding - s.length))
          %Q{<%= color '#{name_column}', :cyan %%> #{AppScrollsScrolls::Scrolls[s].description}}
        end

        say "<%= list(#{scrolls_with_descriptions.inspect}) %>\n"
      end

    end
  end
end
