require 'set'
require 'enumerator'

module RelevanceRails
  class ScrollSet
    include Enumerable
    
    attr_accessor :set

    def initialize(seed=[])
      @set = Set.new(seed)
      classify_scrolls!
    end

    def each(&block)
      @set.each { |item| yield item }
    end

    def union_minus_intersection!(other_scrolls)
      other_scrolls = RelevanceRails::ScrollSet.new(other_scrolls)
      @set.replace @set.union(other_scrolls).subtract(@set.intersection(other_scrolls))
      classify_scrolls!
    end

    def resolved
      ScrollSet.new build_template.resolve_scrolls
    end

    def build_template
      AppScrollsScrolls::Template.new(@set)
    end

    def run(app_name)
      template = build_template
      template_file = Tempfile.new('relevance-rails-template')
      template_file.write template.compile
      template_file.flush

      system "rails new #{app_name} -m #{template_file.path} #{template.args.join(' ')}"
    ensure
      template_file.unlink
    end

    private

    def classify_scrolls!
      unclassified_scrolls = @set.reject do |s|
        s.respond_to?(:superclass) && s.superclass == AppScrollsScrolls::Scroll
      end

      unclassified_scrolls.each do |scroll|
        classified = AppScrollsScrolls::Scrolls[scroll]
        @set.delete(scroll)
        @set.add(classified) if classified
      end

      self
    end

  end
end