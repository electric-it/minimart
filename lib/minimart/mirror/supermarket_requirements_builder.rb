require 'minimart/inventory_requirement/base_requirement'

module Minimart
  module Mirror
    class SupermarketRequirementsBuilder

      attr_reader :name
      attr_reader :versions

      def initialize(name, reqs)
        @name     = name
        @versions = reqs.fetch('versions', [])
        @versions = [@versions] if @versions.is_a? String
      end

      def build
        versions.map do |v|
          InventoryRequirement::BaseRequirement.new(name, version_requirement: v)
        end
      end
    end
  end
end
