module Minimart
  class Mirror
    class Source

      attr_reader :url,
                  :cookbooks

      def initialize(opts)
        @url       = opts['url']
        @cookbooks = opts['cookbooks']
      end

      def download_cookbooks(&block)
        cookbooks.each do |cookbook_name, attrs|
          attrs['versions'].each do |version|
            fetch_cookbook(cookbook_name, version, &block)
          end
        end
      end

      private

      def universe
        @universe ||= fetch_universe
      end

      def fetch_universe
        Minimart::Configuration.output.puts "Fetching the universe for #{url} ..."
        universe = JSON.parse(RestClient.get(URI.join(url, '/universe').to_s))

        result = []
        universe.each do |cookbook_name, versions|
          versions.each do |version, attrs|
            result << Hashie::Mash.new(
              name:          cookbook_name,
              version:       version,
              dependencies:  attrs['dependencies'],
              location_path: attrs['location_path'],
              download_url:  attrs['download_url'])
          end
        end

        result
      end

      def fetch_cookbook(cookbook_name, cookbook_version, &block)
        Minimart::Configuration.output.puts "Downloading #{cookbook_name} #{cookbook_version}"
        cookbook = find_cookbook(cookbook_name, cookbook_version)

        block.call(cookbook, download_cookbook_archive_file(cookbook))

        cookbook.dependencies.each do |dependency_name, dependency_requirements|
          version = resolve_dependency(dependency_name, dependency_requirements)
          fetch_cookbook(dependency_name, version, &block)
        end
      end

      def find_cookbook(cookbook_name, version)
        universe.select do |cookbook|
          cookbook.name == cookbook_name && cookbook.version == version
        end.first
      end

      def download_cookbook_archive_file(cookbook)
        result = Tempfile.new("#{cookbook.name}-#{cookbook.version}")
        result.binmode
        result.write(RestClient.get(cookbook.download_url))
        result.close(false)
        result
      end

      def resolve_dependency(cookbook_name, requirements)
        Solve.it!(dependency_graph, [[cookbook_name, requirements]])[cookbook_name]
      end

      def dependency_graph
        @dependency_graph ||= Solve::Graph.new.tap do |graph|
          universe.each do |remote_cookbook|
            graph.artifact(remote_cookbook.name, remote_cookbook.version)
          end
        end
      end

    end
  end
end
