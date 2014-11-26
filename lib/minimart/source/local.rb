module Minimart
  class Source
    class Local

      attr_reader :inventory_directory

      def initialize(inventory_directory)
        @inventory_directory = inventory_directory
        @dependency_graph    = Solve::Graph.new
      end

    end
  end
end
