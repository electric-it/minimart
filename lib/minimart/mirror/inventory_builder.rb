module Minimart
  class Mirror
    class InventoryBuilder

      attr_reader :inventory_configuration,
                  :dependency_graph,
                  :local_store

      def initialize(inventory_directory, inventory_configuration)
        @inventory_configuration = inventory_configuration
        @dependency_graph        = DependencyGraph.new
        @local_store             = LocalStore.new(inventory_directory)
      end

      def build!
        download_cookbooks_with_location_specifications
        build_dependency_graph
        fetch_inventory
      end

      private

      def download_cookbooks_with_location_specifications
        inventory_cookbooks.each do |inventory_cookbook|
          next unless inventory_cookbook.location_specification?

          dependency_graph.add_remote_cookbook(inventory_cookbook.cookbook_info)
          local_store.add_cookbook_from_directory(inventory_cookbook.cookbook_path)
        end
      end

      def build_dependency_graph
        add_cookbooks_to_dependency_graph
        add_requirements_to_dependency_graph
      end

      def add_cookbooks_to_dependency_graph
        sources.each do |source|
          source.cookbooks.each do |cookbook|
            dependency_graph.add_remote_cookbook(cookbook)
          end
        end
      end

      def add_requirements_to_dependency_graph
        inventory_cookbooks.each do |cookbook|
          dependency_graph.add_inventory_requirement(cookbook.requirements)
        end
      end

      def fetch_inventory
        dependency_graph.resolved_requirements.each do |resolved_requirement|
          name, version   = resolved_requirement
          next if local_store.installed?(name, version)

          path = Download::Supermarket.download(find_remote_cookbook(name, version))
          local_store.add_cookbook_from_directory(path)
        end
      end

      def find_remote_cookbook(name, version)
        sources.each do |source|
          result = source.find_cookbook(name, version)
          return result unless result.nil?
        end

        raise CookbookNotFound, "The cookbook #{name} with the version #{version} could not be found"
      end

      def inventory_cookbooks
        inventory_configuration.cookbooks
      end

      def sources
        inventory_configuration.sources
      end

    end

    class CookbookNotFound < Exception; end
  end
end
