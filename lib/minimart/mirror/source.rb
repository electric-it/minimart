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
            cookbook = find_cookbook(cookbook_name, version)
            fetch_cookbook(cookbook, &block)
          end
        end
      end

      private

      def find_cookbook(cookbook_name, version)
        universe.select do |cookbook|
          cookbook.name == cookbook_name && cookbook.version == version
        end.first
      end

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
              name: cookbook_name,
              version: version,
              dependencies: attrs['dependencies'],
              location_path: attrs['location_path'],
              download_url: attrs['download_url'])
          end
        end

        result
      end

      def fetch_cookbook(cookbook, &block)
        Minimart::Configuration.output.puts "Downloading #{cookbook.name} #{cookbook.version}"
        temp = Tempfile.new("#{cookbook.name}-#{cookbook.version}")
        temp.binmode
        temp.write(RestClient.get(cookbook.download_url))
        temp.close(false)
        block.call(cookbook, temp)

        cookbook.dependencies.each do |dependency_name, dependency_requirements|
          version = resolve_dependency(dependency_name, dependency_requirements)[dependency_name]
          dep_book = find_cookbook(dependency_name, version)
          fetch_cookbook(dep_book, &block)
        end
      end

      def resolve_dependency(cookbook_name, requirements)
        Solve.it!(dependency_graph, [[cookbook_name, requirements]])
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


__END__
base_source:
url: "https://supermarket.getchef.com"
cookbooks:
  yum:
    versions:
    - 3.4.1
    - 3.1.0
