module Minimart
  module Mirror

    # Source represents a single remote source to fetch cookbooks from.
    # Each source is specified in the inventory using the 'sources' key.
    class Source

      # @return [String] The URL for this source
      attr_accessor :base_url

      # @param [String] base_url The URL for this source
      def initialize(base_url)
        @base_url = base_url
      end

      # Search through the cookbooks available at this source, and return
      # the relevant version if it is available.
      # @return [Minimart::Mirror::RemoteCookbook]
      def find_cookbook(cookbook_name, version)
        cookbooks.find do |cookbook|
          cookbook.name == cookbook_name && cookbook.version == version
        end
      end

      # Query this source for it's available cookbooks using the '/universe' endpoint.
      # @return [Array<Minimart::Mirror::RemoteCookbook]
      def cookbooks
        @cookbooks ||= fetch_universe_data.each_with_object([]) do |cookbook_info, memo|
          name, versions = cookbook_info
          memo.concat versions.map { |version, attrs| build_cookbook(name, version, attrs) }
        end
      end

      def to_s
        base_url
      end

      private

      def build_cookbook(name, version, attrs)
        attrs = attrs.merge(name: name, version: version)
        RemoteCookbook.new(attrs)
      end

      def fetch_universe_data
        Configuration.output.puts "Fetching the universe for #{universe_url} ..."

        Utils::Http.get_json(universe_url)

      rescue RestClient::ResourceNotFound
        raise Error::UniverseNotFoundError.new "no universe found for #{base_url}"
      end

      def universe_url
        Utils::Http.build_url(base_url, 'universe')
      end
    end
  end
end
