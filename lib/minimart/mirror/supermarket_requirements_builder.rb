require 'minimart/inventory_requirement/base_requirement'

module Minimart
  module Mirror

    # This class is used to parse any Supermarket requirements specified in the inventory
    # and build Minimart::Inventory::BaseRequirements from them.
    class SupermarketRequirementsBuilder

      # @return [String] the name of the cookbook
      attr_reader :name

      # @return [Array<String>] an array of versions to fetch for this cookbook
      attr_reader :versions

      # @param [String] name The name of the cookbook
      # @param [Hash] reqs
      #   * 'versions' [Array<String>] A listing of versions to fetch.
      #   * 'version' [String] A single version to fetch.
      def initialize(name, reqs)
        @name     = name
        @versions = reqs['versions'] || reqs['version'] || []
        @versions = [@versions] if @versions.is_a? String
      end

      # Build the Supemarket requirements.
      # @return [Array<Minimart::InventoryRequirement::BaseRequirement>]
      def build
        versions.map do |v|
          InventoryRequirement::BaseRequirement.new(name, version_requirement: v)
        end
      end
    end
  end
end
