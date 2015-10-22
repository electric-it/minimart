require 'solve'

module Minimart
  module Mirror

    # A dependency graph for managing any remote cookbooks and their dependencies.
    # This can be used to resolve any requirements found in the inventory file.
    class DependencyGraph


      attr_reader :graph
      attr_reader :inventory_requirements

      def initialize
        @graph = Solve::Graph.new
        @inventory_requirements = []
      end

      # Add an artifact (cookbook), to the graph.
      # @param [Minimart::Mirror::SourceCookbook] cookbook
      def add_artifact(cookbook)
        return if source_cookbook_added?(cookbook.name, cookbook.version)

        graph.artifact(cookbook.name, cookbook.version).tap do |artifact|
          if load_dependencies?
            cookbook.dependencies.each do |dependency|
              name, requirements = dependency
              artifact.depends(name, requirements)
            end
          end
        end
      end

      # Determine whether or not the graph has a given cookbook.
      # @param [String]  name The name of the cookbook
      # @param [String]  version The version of the cookbook
      # @return [Boolean]
      def source_cookbook_added?(name, version)
        graph.artifact?(name, version)
      end

      # Get a cookbook out of the graph.
      # @param [Minimart::Mirror::SourceCookbook] cookbook The cookbook to fetch.
      # @return [Solve::Artifact]
      def find_graph_artifact(cookbook)
        graph.find(cookbook.name, cookbook.version)
      end

      # Add a new requirement to be resolved by the graph
      # @param [Hash] requirements (ex. { 'minimart' => '> 0.0.1' })
      def add_requirement(requirements = {})
        inventory_requirements.concat(requirements.to_a)
      end

      # Resolve any requirements against the graph
      # @return [Array] The requirements as resolved by the graph (ex. [['minimart', '0.0.5']])
      # @raise [Minimart::Error::UnresolvedDependency] Raised when a dependency cannot be resolved
      def resolved_requirements
        inventory_requirements.inject([]) do |result, requirement|
          result.concat(resolve_requirement(requirement).to_a)
        end
      end

      private

      def load_dependencies?
        Minimart::Configuration.load_deps
      end

      def resolve_requirement(requirement)
        Solve.it!(graph, [requirement])

      rescue Solve::Errors::NoSolutionError => e
        raise Error::UnresolvedDependency, e.message
      end

    end
  end
end
