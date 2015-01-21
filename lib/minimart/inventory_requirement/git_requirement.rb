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
      def location_specification?
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
