module RelevanceRails
  module Scrolls

    def self.load_scrolls
      Pathname.glob(RelevanceRails.root.join('scrolls/*.rb')).each do |scroll_path|
        key = scroll_path.basename('.rb').to_s
        scroll = AppScrollsScrolls::Scroll.generate(key, scroll_path)
        AppScrollsScrolls::Scrolls.add(scroll)
      end
    end

  end
end
