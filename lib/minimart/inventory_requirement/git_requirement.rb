require 'minimart/download/git_repository'

module Minimart
  module InventoryRequirement

    # A single Git requirement for a cookbook as specified in the inventory.
    # This represents a single brach, ref, or tag for a cookbook.
    class GitRequirement < BaseRequirement

      # @return [String] the location to fetch this cookbook from.
      attr_reader :location

      # @return [String] the branch to checkout once this cookbook has been fetched.
      attr_reader :branch

      # @return [String] the SHA of the Git commit to checkout once this cookbook has been fetched.
      attr_reader :ref

      # @return [String] the tag to checkout once this cookbook has been fetched
      attr_reader :tag

      # @param [String] name The name of the cookbook defined by this requirement.
      # @param [Hash] opts
      # @option opts [String] branch The branch to checkout once this cookbook has been fetched.
      # @option opts [String] tag The tag to checkout once this cookbook has been fetched
      # @option opts [String] ref The SHA of the Git commit to checkout once this cookbook has been fetched.
      def initialize(name, opts)
        super
        @branch   = opts[:branch]
        @ref      = opts[:ref]
        @tag      = opts[:tag]
        @location = opts[:location]
      end

      # Git requirements explicitly define their location, so this method will return true.
      # @return [Boolean] TRUE
      def explicit_location?
        true
      end

      # Convert this requirement to a hash
      # @return [Hash]
      def to_hash
        result = super
        result[:source_type]    = :git
        result[:location]       = location
        result[:commitish_type] = commitish_type
        result[:commitish]      = commitish
        result
      end

      # Determine if a Git cookbook in the inventory has metadata matching this requirement.
      # This method will return true if the metadata has the same commit information
      # as this requirement.
      # @param [Minimart::Mirror::DownloadMetadata] metadata The download metadata for a cookbook
      #   in the inventory.
      # @return [Boolean] Defaults to true
      def matching_source?(metadata)
        if metadata.has_key?('metadata_version') && metadata['metadata_version'] == '2.0'
          metadata['source_type'] == 'git' &&
            metadata['location'] == @location &&
            metadata['commitish_type'] == commitish_type.to_s &&
            (metadata['commitish_type'] == 'ref' ? true : metadata['commitish'] == commitish.to_s)
        else
          metadata['source_type'] == 'git' &&
            metadata['commitish_type'] == commitish_type.to_s &&
            (metadata['commitish_type'] == 'ref' ? true : metadata['commitish'] == commitish.to_s)
        end
      end

      private

      def download_cookbook(&block)
        Configuration.output.puts "-- Fetching '#{name}[#{commitish}]' from '#{location}'"

        downloader = Download::GitRepository.new(location)
        downloader.fetch(commitish) do |path_to_cookbook|
          block.call(Minimart::Cookbook.from_path(path_to_cookbook))
        end
      end

      def commitish
        ref || branch || tag
      end

      def commitish_type
        return :ref if ref
        return :branch if branch
        return :tag if tag
      end

    end
  end
end
