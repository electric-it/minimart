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
        cookbook_info.dependencies
      end

      private

      def download_cookbook
        Configuration.output.puts "-- Fetching '#{name}[#{commitish}]' from '#{location}'"

        path = Download::GitRepository.new(location).fetch(commitish)
        Ridley::Chef::Cookbook.from_path(path)
      end

      def commitish
        ref || branch || tag
      end

    end
  end
end
