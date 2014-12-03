module Minimart
  class Mirror
    class Sources < Array

      def initialize(source_urls = [])
        source_urls.each { |source_url| add_source(source_url) }
      end

      def each_cookbook(&block)
        each { |source| source.cookbooks.each(&block) }
      end

      def find_cookbook(name, version)
        each do |source|
          cookbook = source.find_cookbook(name, version)
          return cookbook if cookbook
        end

        raise Error::CookbookNotFound, "The cookbook #{name} with the version #{version} could not be found"
      end

      private

      def add_source(source_url)
        self << Source.new(source_url)
      end
    end
  end
end
