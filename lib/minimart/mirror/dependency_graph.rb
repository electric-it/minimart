module Minimart
  module Mirror
    class DependencyGraph

      attr_reader :graph

      def initialize
        @graph = Solve::Graph.new
      end

      def add_cookbooks(cookbooks)
        cookbooks.each do |cookbook|
          next if graph.artifact?(cookbook.name, cookbook.version)

          graph.artifact(cookbook.name, cookbook.version)

          cookbook.dependencies.each do |dependency|
            name, requirements = dependency
            graph.artifact(cookbook.name, cookbook.version).depends(name, requirements)
          end
        end
      end

    end
  end
end
