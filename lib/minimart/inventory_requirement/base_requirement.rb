module Minimart
  module InventoryRequirement
    class BaseRequirement

      attr_reader :name,
                  :version_requirement,
                  :cached_cookbook,
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

      def cookbook_info
        return cookbook.metadata if cookbook
      end

      def cookbook_path
        return cookbook.path if cookbook
      end

      def fetch_cookbook
        @cookbook ||= download_cookbook
      end

      def to_demand
        [name, version_requirement]
      end

      def version_requirement?
        !!version_requirement
      end

      private

      def download_cookbook
        nil
      end

    end
  end
end
