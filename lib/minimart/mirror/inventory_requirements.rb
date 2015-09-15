require 'minimart/inventory_requirement/supermarket_requirements_builder'
require 'minimart/inventory_requirement/git_requirements_builder'
require 'minimart/inventory_requirement/local_requirements_builder'

module Minimart
  module Mirror

    # The collection of requirements as defined in the inventory file.
    class InventoryRequirements
      include Enumerable

      # @return [Hash<String, Hash>] The cookbooks listed in the inventory file
      attr_reader :raw_cookbooks

      # @param [Hash<String, Hash>] raw_cookbooks The cookbooks listed in the inventory file
      def initialize(raw_cookbooks)
        @raw_cookbooks = raw_cookbooks
        @requirements  = {}

        parse_cookbooks
      end

      # Iterate over the requirements
      # @yield [Minimart::Inventory::BaseRequirement]
      def each(&block)
        requirements.values.flatten.each &block
      end

      def each_with_explicit_location(&block)
        each do |req|
          block.call(req) if req.explicit_location?
        end
      end

      # This method will determine whether or not a version of a cookbook
      # resolves a constraint defined in the inventory file. This method
      # can be used to verify that we aren't downloading a non specified version
      # of a cookbook (e.g. possibly downloading cookbooks that a user wants,
      # but in versions that they do not)
      # @param [String] name The name of the cookbook to verify
      # @param [String] version The cookbook version to check
      # @return [Boolean] Return true if this version solves a requirement
      #   as specified in the inventory. This method will also return true for
      #   any cookbooks not specified in the inventory.
      def version_required?(name, version)
        (!has_cookbook?(name)) ||
          solves_explicit_requirement?(name, version)
      end

      private

      attr_reader :requirements

      def has_cookbook?(name)
        requirements.has_key?(name)
      end

      def solves_explicit_requirement?(name, version)
        requirements[name].each do |req|
          next unless req.version_requirement?
          return true if Semverse::Constraint.new(req.version_requirement).satisfies?(version)
        end
        return false
      end

      # Build Minimart::Inventory requirements from the inventory.
      def parse_cookbooks
        raw_cookbooks.each do |name, reqs|
          @requirements[name] = build_requirements_for(name, (reqs || {}))
        end
      end

      def build_requirements_for(name, reqs)
        get_requirements_for(name, reqs).tap do |parsed_requirements|
          validate_requirements(name, parsed_requirements)
        end
      end

      def get_requirements_for(name, reqs)
        (market_requirements(name, reqs) +
          git_requirements(name, reqs) +
          local_path_requirements(name, reqs)).flatten.compact
      end

      def validate_requirements(name, reqs)
        return unless reqs.nil? || reqs.empty?
        raise Minimart::Error::InvalidInventoryError,
          "Minimart could not find any requirements for '#{name}'"
      end

      def market_requirements(name, reqs)
        InventoryRequirement::SupermarketRequirementsBuilder.new(name, reqs).build
      end

      def git_requirements(name, reqs)
        InventoryRequirement::GitRequirementsBuilder.new(name, reqs).build
      end

      def local_path_requirements(name, reqs)
        InventoryRequirement::LocalRequirementsBuilder.new(name, reqs).build
      end
    end
  end
end
