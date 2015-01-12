module Minimart
  class Mirror
    class Source

      attr_accessor :base_url

      def initialize(base_url)
        @base_url = base_url
      end

      def find_cookbook(cookbook_name, version)
        cookbooks.find do |cookbook|
          cookbook.name == cookbook_name && cookbook.version == version
        end
      end

      def cookbooks
        @cookbooks ||= fetch_universe_data.each_with_object([]) do |cookbook_info, memo|
          name, versions = cookbook_info
          memo.concat versions.map { |version, attrs| build_cookbook(name, version, attrs) }
        end
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
        src_url = base_url[-1, 1] == '/' ? base_url : "#{base_url}/"
        URI.join("#{base_url}/", 'universe')
      end
    end
  end
end
