module Minimart
  module InventoryCookbook
    class BaseCookbook

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

      def cookbook
        raise 'not implemented'
      end

      def requirements
        {name => version_requirement}
      end

    end
  end
end
