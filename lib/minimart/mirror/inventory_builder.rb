require 'minimart/download/supermarket'

module Minimart
  module Mirror
    class InventoryBuilder

      attr_reader :inventory_configuration,
                  :graph,
                  :local_store

      # @param [String] inventory_directory The directory to store the inventory.
      # @param [Minimart::Mirror::InventoryConfiguration] The inventory as defined by a user of Minimart.
      def initialize(inventory_directory, inventory_configuration)
        @graph                   = DependencyGraph.new
        @local_store             = LocalStore.new(inventory_directory)
        @inventory_configuration = inventory_configuration
      end

      # Build the inventory!
      def build!
        install_cookbooks_with_location_dependency
        add_remote_cookbooks_to_graph
        add_requirements_to_graph
        fetch_inventory
      end

      private

      # First we must install any cookbooks with a location specification (git, local path, etc..).
      # These cookbooks and their associated metadata (any dependencies they have) take
      # precedence over information found elsewhere.
      def install_cookbooks_with_location_dependency
        inventory_requirements.each do |requirement|
          next unless requirement.location_specification?

          requirement.fetch_cookbook
          add_artifact_to_graph(requirement.cookbook_info)
          add_cookbook_to_local_store(requirement.cookbook_path)
        end
      end

      # Fetch the universe from any of the defined sources, and add them as artifacts
      #  to the dependency resolution graph.
      def add_remote_cookbooks_to_graph
        sources.each_cookbook do |cookbook|
          add_artifact_to_graph(cookbook)
        end
      end

      # Add any cookbooks defined in the inventory file as requirements to the graph
      def add_requirements_to_graph
        inventory_requirements.each do |cookbook_requirement|
          add_requirement_to_graph(cookbook_requirement.requirements)
        end
      end

      def fetch_inventory
        resolved_requirements.each do |resolved_requirement|
          install_cookbook(*resolved_requirement)
        end
      end

      def resolved_requirements
        graph.resolved_requirements
      end

      def install_cookbook(name, version)
        if cookbook_already_installed?(name, version)
          Configuration.output.puts("cookbook already installed: #{name}-#{version}.")
          return
        end

        verify_dependency_can_be_installed(name, version)

        Download::Supermarket.download(find_cookbook(name, version)) do |cookbook_path|
          add_cookbook_to_local_store(cookbook_path)
        end
      end

      def cookbook_already_installed?(name, version)
        local_store.installed?(name, version)
      end

      def verify_dependency_can_be_installed(name, version)
        return unless non_required_version?(name, version)

        msg = "The dependency #{name}-#{version} could not be installed."
        msg << " This is because a cookbook listed in the inventory depends on a version of '#{name}'"
        msg << " that does not match the explicit requirements for the '#{name}' cookbook."
        raise Error::BrokenDependency, msg
      end

      def non_required_version?(name, version)
        !inventory_requirements.version_required?(name, version)
      end

      def add_cookbook_to_local_store(cookbook_path)
        local_store.add_cookbook_from_path(cookbook_path)
      end

      def download_cookbook(name, version)

      end

      def find_cookbook(name, version)
        sources.find_cookbook(name, version)
      end

      def add_artifact_to_graph(cookbook)
        graph.add_artifact(cookbook)
      end

      def add_requirement_to_graph(requirements)
        graph.add_requirement(requirements)
      end

      def inventory_requirements
        inventory_configuration.requirements
      end

      def sources
        inventory_configuration.sources
      end
    end
  end
end
