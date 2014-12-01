module Minimart
  module InventoryCookbook
    class GitCookbook < BaseCookbook

      attr_reader :name,
                  :branch,
                  :ref,
                  :tag

      def initialize(name, opts)
        super

        @branch = opts[:branch]
        @ref    = opts[:ref]
        @tag    = opts[:tag]
      end

      def location_specification?
        true
      end

    end
  end
end
