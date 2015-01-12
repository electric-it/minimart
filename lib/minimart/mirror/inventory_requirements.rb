require 'minimart/mirror/supermarket_requirements_builder'
require 'minimart/mirror/git_requirements_builder'
require 'minimart/mirror/local_requirements_builder'

module Minimart
  class Mirror
    class InventoryRequirements
      include Enumerable

      attr_reader :raw_cookbooks

      attr_reader :requirements

      def initialize(raw_cookbooks)
        @raw_cookbooks = raw_cookbooks
        @requirements  = {}

        parse_cookbooks
      end

      def each(&block)
        requirements.values.flatten.each &block
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

      def has_cookbook?(name)
        requirements.has_key?(name)
      end

      def solves_explicit_requirement?(name, version)
        graph = Solve::Graph.new.tap { |g| g.artifact(name, version) }

        requirements[name].each do |req|
          next unless req.version_requirement?

          begin
            return true if Solve.it!(graph, [req.to_demand])
          rescue Solve::Errors::NoSolutionError
          end
        end

        return false
      end

      def parse_cookbooks
        raw_cookbooks.each do |name, reqs|
          @requirements[name] = build_requirements_for(name, reqs)
        end
      end

      def build_requirements_for(name, reqs)
        (market_requirements(name, reqs) +
          git_requirements(name, reqs) +
          local_path_requirements(name, reqs)).flatten.compact
      end

      def market_requirements(name, reqs)
        SupermarketRequirementsBuilder.new(name, reqs).build
      end

      def git_requirements(name, reqs)
        GitRequirementsBuilder.new(name, reqs).build
      end

      def local_path_requirements(name, reqs)
        LocalRequirementsBuilder.new(name, reqs).build
      end
    end
  end
end
