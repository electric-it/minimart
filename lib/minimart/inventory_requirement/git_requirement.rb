require 'minimart/download/git_repository'

module Minimart
  module InventoryRequirement
    class GitRequirement < BaseRequirement

      attr_reader :location,
                  :branch,
                  :ref,
                  :tag

      def initialize(name, opts)
        super
        @branch   = opts[:branch]
        @ref      = opts[:ref]
        @tag      = opts[:tag]
        @location = opts[:location]
      end

      def location_specification?
        true
      end

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
          block.call(Minimart::Cookbook.new(path_to_cookbook))
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
