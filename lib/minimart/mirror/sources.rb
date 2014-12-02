module Minimart
  class Mirror
    class Sources

      attr_reader :sources

      def initialize(source_urls = [])
        @sources = []
        source_urls.each { |source_url| add_source(source_url) }
      end

      def each_cookbook(&block)
        sources.each { |source| source.cookbooks.each &block }
      end

      def find_cookbook(name, version)
        sources.each do |source|
          cookbook = source.find_cookbook(name, version)
          return cookbook if cookbook
        end

        raise CookbookNotFound, "The cookbook #{name} with the version #{version} could not be found"
      end

      private

      def add_source(source_url)
        sources << Source.new(source_url)
      end
    end

    class CookbookNotFound < Exception; end
  end
end
