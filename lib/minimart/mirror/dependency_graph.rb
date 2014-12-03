require 'solve'

##
# A class for managing a listing of remote cookbooks and their dependencies.
# This can be used to resolve any requirements found in the inventory file.
##
module Minimart
  class Mirror
    class DependencyGraph

      attr_reader :graph,
                  :inventory_requirements

      def initialize
        @graph = Solve::Graph.new
        @inventory_requirements = []
      end

      def add_remote_cookbook(cookbook)
        return if remote_cookbook_added?(cookbook.name, cookbook.version)

        graph.artifact(cookbook.name, cookbook.version)

        cookbook.dependencies.each do |dependency|
          name, requirements = dependency
          graph.artifact(cookbook.name, cookbook.version).depends(name, requirements)
        end
      end

      def remote_cookbook_added?(name, version)
        graph.artifact?(name, version)
      end

      def find_graph_artifact(cookbook)
        graph.find(cookbook.name, cookbook.version)
      end

      def add_inventory_requirement(requirements = {})
        inventory_requirements.concat(requirements.to_a)
      end

      def resolved_requirements
        inventory_requirements.inject([]) do |result, requirement|
          result.concat(resolve_requirement(requirement).to_a)
        end
      end

      private

      def resolve_requirement(requirement)
        Solve.it!(graph, [requirement])

      rescue Solve::Errors::NoSolutionError => e
        raise UnresolvedDependency, e.message
      end

    end

    class UnresolvedDependency < Exception; end
  end
end
