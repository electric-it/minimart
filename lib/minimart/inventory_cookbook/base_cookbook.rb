module Minimart
  module InventoryCookbook
    class BaseCookbook

      attr_reader :name,
                  :version_requirement

      def initialize(name, opts)
        @name = name
        @version_requirement = opts[:version_requirement]
      end

      def location_specification?
        false
      end

      def install
        raise 'not implemented'
      end

    end
  end
end
