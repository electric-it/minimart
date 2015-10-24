module Minimart
  module Mirror

    # InventoryBuilder coordinates downloading any cookbooks, and their dependencies.
    class InventoryBuilder

      attr_reader :inventory_configuration, :graph, :local_store

      # @param [String] inventory_directory The directory to store the inventory.
      # @param [Minimart::Mirror::InventoryConfiguration] inventory_configuration The inventory as defined by a user of Minimart.
      def initialize(inventory_directory, inventory_configuration)
        @graph                   = DependencyGraph.new
        @local_store             = LocalStore.new(inventory_directory)
        @inventory_configuration = inventory_configuration
      end

      # Build the inventory!
      def build!
        install_cookbooks_with_explicit_location
        add_source_cookbooks_to_graph
        add_requirements_to_graph
        fetch_inventory
        display_success_message

      ensure
        clear_cache
      end

      private

      # First we must install any cookbooks with a location specification (git, local path, etc..).
      # These cookbooks and their associated metadata (any dependencies they have) take
      # precedence over information found elsewhere.
      def install_cookbooks_with_explicit_location
        inventory_requirements.each_with_explicit_location do |requirement|
          requirement.fetch_cookbook do |cookbook|
            validate_cookbook_against_local_store(cookbook, requirement)
            add_artifact_to_graph(cookbook)
            add_cookbook_to_local_store(cookbook.path, requirement.to_hash)
          end
        end
      end

      # Fetch the universe from any of the defined sources, and add them as artifacts
      #  to the dependency resolution graph.
      def add_source_cookbooks_to_graph
        sources.each_cookbook { |cookbook| add_artifact_to_graph(cookbook) }
      end

      # Add any cookbooks defined in the inventory file as a requirement to the graph
      def add_requirements_to_graph
        inventory_requirements.each do |requirement|
          graph.add_requirement(requirement.requirements)
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
          Configuration.output.puts_yellow("cookbook already installed: #{name}-#{version}.")
          return
        end

        verify_dependency_can_be_installed(name, version)

        source_cookbook = cookbook_from_source(name, version)
        source_cookbook.fetch do |cookbook|
          add_cookbook_to_local_store(cookbook.path, source_cookbook.to_hash)
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

      # We need to validate that if this cookbook is in the store
      # it came from the same source, otherwise we could
      # possibly override a cookbook
      def validate_cookbook_against_local_store(cookbook, requirement)
        local_store.validate_resolved_requirement(cookbook, requirement)
      end

      def add_cookbook_to_local_store(cookbook_path, data = {})
        local_store.add_cookbook_from_path(cookbook_path, data)
      end

      def cookbook_from_source(name, version)
        sources.find_cookbook(name, version)
      end

      def add_artifact_to_graph(cookbook)
        graph.add_artifact(cookbook)
      end

      def inventory_requirements
        inventory_configuration.requirements
      end

      def sources
        inventory_configuration.sources
      end

      def display_success_message
        Configuration.output.puts_green %{Minimart is done building your inventory!}
        Configuration.output.puts_green %{The inventory can be found in #{local_store.directory_path}}
      end

      def clear_cache
        Minimart::Download::GitCache.instance.clear
      end

    end
  end
end
