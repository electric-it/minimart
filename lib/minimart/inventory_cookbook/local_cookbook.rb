module Minimart
  module InventoryCookbook
    class LocalCookbook < BaseCookbook

      attr_reader :path

      def initialize(name, opts)
        super
        @path = opts[:path]
      end

      def location_specification?
        true
      end

      def requirements
        cookbook_info.dependencies
      end

      private

      def fetch_cookbook
        Configuration.output.puts "-- Fetching '#{name}' from path '#{path}'"
        Ridley::Chef::Cookbook.from_path(path)
      end

    end
  end
end
