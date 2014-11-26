module Minimart
  class Source
    class Universe

      attr_accessor :base_url

      def initialize(base_url)
        @base_url = base_url
      end

      def find_cookbook(cookbook_name, version)
        index = cookbooks.find_index do |cookbook|
          cookbook.name == cookbook_name && cookbook.version == version
        end
        cookbooks[index] unless index.nil?
      end

      def find_cookbook_for_requirements(cookbook_name, requirements)
        find_cookbook(cookbook_name, resolve_dependency!(cookbook_name, requirements))
      end

      def resolve_dependency(cookbook_name, requirements)
        resolve_dependency!(cookbook_name, requirements)

      rescue DependencyNotMet
        return nil
      end

      private

      def resolve_dependency!(cookbook_name, requirements)
        Solve.it!(dependency_graph, [[cookbook_name, requirements]])[cookbook_name]

      rescue Solve::Errors::NoSolutionError
        raise DependencyNotMet, "could not fulfill dependency #{cookbook_name} with requirements `#{requirements}`"
      end

      def cookbooks
        @cookbooks ||= fetch_universe_data.each_with_object([]) do |cookbook_info, memo|
          name, versions = cookbook_info
          memo.concat versions.map { |version, attrs| build_cookbook(name, version, attrs) }
        end
      end

      def build_cookbook(name, version, attrs)
        Hashie::Mash.new(
          name:          name,
          version:       version,
          dependencies:  attrs['dependencies'],
          location_path: attrs['location_path'],
          download_url:  attrs['download_url'])
      end

      def dependency_graph
        @dependency_graph ||= Solve::Graph.new.tap do |graph|
          cookbooks.each do |remote_cookbook|
            graph.artifact(remote_cookbook.name, remote_cookbook.version)
          end
        end
      end

      def fetch_universe_data
        Configuration.output.puts "Fetching the universe for #{universe_url} ..."

        Utils::Http.get_json(universe_url)

      rescue RestClient::ResourceNotFound
        raise UniverseNotFoundError.new "no universe found for #{base_url}"
      end

      def universe_url
        src_url = base_url[-1, 1] == '/' ? base_url : "#{base_url}/"
        URI.join("#{base_url}/", 'universe')
      end
    end

    class UniverseNotFoundError < Exception; end
    class DependencyNotMet < Exception; end
  end
end
