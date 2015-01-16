require 'minimart/cookbook'
require 'forwardable'

module Minimart
  module Web
    # Given a path to the inventory directory, this class will generate the necessary
    # JSON output to power the main dashboard, and return cookbooks in a format
    # that can be used to build the various web pages.
    class Cookbooks
      extend Forwardable

      include Enumerable

      FILE_NAME = 'data.json'

      attr_reader :inventory_directory

      def initialize(opts)
        @inventory_directory = opts[:inventory_directory]
        generate
      end

      def to_json
        map do |cookbook_name, cookbook_versions|
          cookbook_versions.first.to_hash.merge(available_versions: cookbook_versions.size)
        end.to_json
      end

      def_delegators :data_structure, :each, :keys, :values, :[]

      def individual_cookbooks
        values.flatten
      end

      private

      def generate
        build_data_structure
        sort_data
      end

      attr_reader :data_structure

      def build_data_structure
        @data_structure = cookbooks.inject({}) do |memo, cookbook|
          memo[cookbook.name] ||= []
          memo[cookbook.name] << cookbook
          memo
        end
      end

      def sort_data
        data_structure.values.map! do |versions|
          versions.sort! do |a, b|
            Gem::Version.new(b.version) <=> Gem::Version.new(a.version)
          end
        end
      end

      def cookbooks
        inventory_cookbook_paths.map { |path| Minimart::Cookbook.new(path) }
      end

      def inventory_cookbook_paths
        Utils::FileHelper.find_cookbooks_in_directory(inventory_directory)
      end

    end
  end
end
