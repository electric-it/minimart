module Minimart
  module InventoryRequirement
    class LocalPathRequirement < BaseRequirement

      attr_reader :path

      def initialize(name, opts)
        super
        @path = opts[:path]
      end

      def location_specification?
        true
      end

      def requirements
        cookbook.dependencies
      end

      def requirement_data
        super.tap do |data|
          data[:source]   = :local_path
        end
      end

      private

      def download_cookbook(&block)
        Configuration.output.puts "-- Fetching '#{name}' from path '#{path}'"
        block.call(Minimart::Cookbook.new(path))
      end

    end
  end
end
