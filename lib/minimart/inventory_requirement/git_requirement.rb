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

      def requirements
        cookbook.dependencies
      end

      def requirement_data
        super.tap do |data|
          data[:source]   = :git
          data[:location] = location
          data[:branch]   = branch if branch
          data[:ref]      = ref if ref
          data[:tag]      = tag if tag
        end
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

    end
  end
end
