module Minimart
  class Mirror
    class Source

      attr_reader :url,
                  :cookbooks

      def initialize(url, cookbooks)
        @url       = url
        @cookbooks = cookbooks
      end

      def download_cookbooks(&block)
        cookbooks.each do |cookbook_name, attrs|
          attrs['versions'].each do |version|
            fetch_cookbook(cookbook_name, version, &block)
          end
        end
      end

      private

      def fetch_cookbook(cookbook_name, cookbook_version, &block)
        cookbook = universe.find_cookbook(cookbook_name, cookbook_version)

        block.call(cookbook, download_cookbook_archive_file(cookbook))

        cookbook.dependencies.each do |dependency_name, dependency_requirements|
          version = universe.resolve_dependency(dependency_name, dependency_requirements)
          fetch_cookbook(dependency_name, version, &block)
        end
      end

      def download_cookbook_archive_file(cookbook)
        Configuration.output.puts "Downloading #{cookbook.name} #{cookbook.version}"

        result = Tempfile.new("#{cookbook.name}-#{cookbook.version}")
        result.binmode
        result.write(RestClient.get(cookbook.download_url))
        result.close(false)
        result
      end

      def universe
        @universe ||= Universe.new(url)
      end

    end
  end
end
