require 'set'

module RelevanceRails
  module Scrolls

    def self.load_scrolls
      Pathname.glob(RelevanceRails.root.join('scrolls/*.rb')).each do |scroll_path|
        key = scroll_path.basename('.rb').to_s
        scroll = AppScrollsScrolls::Scroll.generate(key, scroll_path)
        AppScrollsScrolls::Scrolls.add(scroll)
      end
    end

    def self.union_minus_intersection(scrolls, other_scrolls)
      set_a, set_b = scrolls.to_set, other_scrolls.to_set
      (set_a + set_b) - (set_a & set_b)
    end

  end
end
