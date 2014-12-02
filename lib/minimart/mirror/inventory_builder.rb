module Minimart
  class Mirror
    class InventoryBuilder

      attr_reader :sources,
                  :inventory_cookbooks,
                  :dependency_graph,
                  :local_store

      def initialize(inventory_directory, sources, inventory_cookbooks)
        @sources             = sources
        @inventory_cookbooks = inventory_cookbooks
        @dependency_graph    = DependencyGraph.new
        @local_store         = LocalStore.new(inventory_directory)
      end

      def build!
        download_cookbooks_with_location_specifications
        build_dependency_graph
        fetch_inventory
      end

      private

      def download_cookbooks_with_location_specifications
        # commenting out until this is redone
        # inventory_cookbooks.each do |inventory_cookbook|
        #   next unless inventory_cookbook.location_specification?
        #   cookbook = inventory_cookbook.install(inventory_directory)
        #   dependency_graph.add_remote_cookbook(cookbook)
        # end
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
          dependency_graph.add_inventory_requirement(cookbook)
        end
      end

      def fetch_inventory
        dependency_graph.resolved_requirements.each do |resolved_requirement|
          name, version   = resolved_requirement
          next if local_store.installed?(name, version)

          remote_cookbook = find_remote_cookbook(name, version)
          path = CookbookDownloader.download(remote_cookbook)
          local_store.add_cookbook_from_directory(path)
        end
      end

      def find_remote_cookbook(name, version)
        sources.each do |source|
          result = source.find_cookbook(name, version)
          return result unless result.nil?
        end

        return nil
      end

    end
  end
end
