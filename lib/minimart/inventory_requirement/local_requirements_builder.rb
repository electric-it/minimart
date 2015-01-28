require 'minimart/inventory_requirement/local_path_requirement'

module Minimart
  module InventoryRequirement
    # This class is used to parse any local path requirements specified in the inventory
    # and build Minimart::Inventory::LocalPathRequirements from them.
    class LocalRequirementsBuilder

      # @return [String] the name of the cookbook defined by this requirement.
      attr_reader :name

      # @return [String] the path to the cookbook
      attr_reader :path

      # @param [String] name The name of the cookbook defined by this requirement.
      # @param [Hash] reqs
      # @option reqs [String] 'path' The path to the cookbook
      def initialize(name, reqs)
        @name = name
        @path = reqs['path']
      end

      # Build the local path requirements.
      # @return [Array<Minimart::InventoryRequirement::LocalPathRequirement>]
      def build
        return [] if path.nil? || path.empty?
        [InventoryRequirement::LocalPathRequirement.new(name, path: path)]
      end
    end
  end
end
