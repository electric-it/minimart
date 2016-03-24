module Minimart
  module InventoryRequirement

    # A requirement to a cookbook found in the local file system
    class LocalPathRequirement < BaseRequirement

      # @return [String] the path to the cookbook
      attr_reader :path

      # @param [String] name The name of the cookbook
      # @param [Hash] opts
      # @option opts [String] path The path to the cookbook
      def initialize(name, opts)
        super
        @path = opts[:path]
      end

      # Local path requirements explicitly define their location, so this method will return true.
      # @return [Boolean] TRUE
      def explicit_location?
        true
      end

      # Convert this requirement to a hash
      # @return [Hash]
      def to_hash
        result = super
        result[:path] = @path
        result[:source_type] = :local_path
        result
      end

      def matching_source?(metadata)
        if metadata.has_key?('metadata_version') && metadata['metadata_version'] == '2.0'
          metadata['source_type'] == 'local_path' &&
            metadata['path'] == @path
        else
          metadata['source_type'] == 'local_path'
        end
      end

      private

      def download_cookbook(&block)
        Configuration.output.puts "-- Fetching '#{name}' from path '#{path}'"
        block.call(Minimart::Cookbook.from_path(path))
      end

    end
  end
end
