require 'minimart/inventory_requirement/local_path_requirement'

module Minimart
  module Mirror
    class LocalRequirementsBuilder

      attr_reader :name
      attr_reader :path

      def initialize(name, reqs)
        @name = name
        @path = reqs['path']
      end

      def build
        return [] if path.nil? || path.empty?
        [InventoryRequirement::LocalPathRequirement.new(name, path: path)]
      end
    end
  end
end
