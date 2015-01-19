module Minimart
  module InventoryRequirement
    class BaseRequirement

      attr_reader :name,
                  :version_requirement,
                  :cookbook

      def initialize(name, opts)
        @name = name
        @version_requirement = opts[:version_requirement]
      end

      def location_specification?
        false
      end

      def requirements
        {name => version_requirement}
      end

      def fetch_cookbook(&block)
        download_cookbook do |cookbook|
          @cookbook = cookbook
          block.call(cookbook) if block
        end
      end

      def to_demand
        [name, version_requirement]
      end

      def version_requirement?
        !!version_requirement
      end

      def requirement_data
        {}
      end

      private

      def download_cookbook(&block)
        nil
      end

    end
  end
end
