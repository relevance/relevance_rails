require 'set'
require 'enumerator'
require 'tempfile'

module RelevanceRails
  class ScrollSet
    include Enumerable

    attr_accessor :scrolls

    def initialize(seed=[])
      @scrolls = Set.new(seed)
      classify_scrolls!
    end

    def each(&block)
      @scrolls.each { |item| yield item }
    end

    def union_minus_intersection!(other_scrolls)
      other_scrolls = RelevanceRails::ScrollSet.new(other_scrolls)
      @scrolls.replace @scrolls.union(other_scrolls).subtract(@scrolls.intersection(other_scrolls))
      classify_scrolls!
    end

    def build_template
      temp = AppScrollsScrolls::Template.new(@scrolls)
      puts "temp root: #{temp.class.template_root}"
      temp
    end

    def resolved
      ScrollSet.new build_template.resolve_scrolls
    end

    def run(app_name)
      template = build_template
      template_file = Tempfile.new('relevance-rails-template')
      template_file.write template.compile
      template_file.flush

      cmd = "rails new #{app_name} -m #{template_file.path} #{template.args.flatten.map(&:strip).join(' ')}"
      defined?(Bundler) ? Bundler.clean_system(cmd) : system(cmd)
    ensure
      template_file.unlink
    end

    private

    def classify_scrolls!
      unclassified_scrolls = @scrolls.reject do |s|
        s.respond_to?(:superclass) && s.superclass == AppScrollsScrolls::Scroll
      end

      unclassified_scrolls.each do |scroll|
        classified = AppScrollsScrolls::Scrolls[scroll]
        @scrolls.delete(scroll)
        @scrolls.add(classified) if classified
      end

      self
    end

  end
end
