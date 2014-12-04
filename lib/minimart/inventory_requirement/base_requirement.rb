module Minimart
  module InventoryRequirement
    class BaseRequirement

      attr_reader :name,
                  :version_requirement,
                  :cached_cookbook

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

      def cookbook
        @cookbook ||= fetch_cookbook
      end

      private

      def fetch_cookbook
        nil
      end

    end
  end
end
