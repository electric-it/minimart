module Minimart
  module Mirror
    # A collection of Minimart::Mirror::Source
    class Sources < Array

      # @param [Array<String>] source_urls An array of source URL's specified in the inventory
      def initialize(source_urls = [])
        source_urls.each { |source_url| add_source(source_url) }
      end

      # Iterate over each cookbook defined in each source
      # @yield [Minimart::Mirror::SourceCookbook]
      def each_cookbook(&block)
        each { |source| source.cookbooks.each(&block) }
      end

      # Find the first cookbook from the avaiable sources with a matching name, and
      # version
      # @param [String] name The name of the cookbook to search for
      # @param [String] version The version of the cookbook to search for
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
