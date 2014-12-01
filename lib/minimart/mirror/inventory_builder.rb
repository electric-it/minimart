module Minimart
  class Mirror
    class InventoryBuilder

      attr_reader :inventory_directory,
                  :sources,
                  :inventory_cookbooks,
                  :dependency_graph

      def initialize(inventory_directory, sources, inventory_cookbooks)
        @inventory_directory = inventory_directory
        @sources             = sources
        @inventory_cookbooks = inventory_cookbooks
        @dependency_graph    = DependencyGraph.new
      end

      def build!
        make_inventory_directory
        build_dependency_graph
        fetch_inventory
      end

      private

      def make_inventory_directory
        Utils::FileHelper.make_directory(inventory_directory)
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
          Configuration.output.puts "-- Downloading #{name} #{version}"

          remote_cookbook = find_remote_cookbook(name, version)
          destination     = File.join(inventory_directory, "#{name}-#{version}")
          CookbookDownloader.download(remote_cookbook, destination)
        end
      end

      def find_remote_cookbook(name, version)
        sources.each do |source|
          result = source.find_cookbook(name, version)
          return result unless result.nil?
        end
      end

    end
  end
end
