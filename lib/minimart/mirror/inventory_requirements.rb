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

      private

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
