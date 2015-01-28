require 'forwardable'

require 'minimart/cookbook'
require 'minimart/utils/file_helper'

module Minimart
  module Web
    # Given a path to the inventory directory, this class will generate the necessary
    # JSON output to power the main dashboard, and return cookbooks in a format
    # that can be used to build the various web pages.
    class Cookbooks
      extend Forwardable

      include Enumerable

      FILE_NAME = 'data.json'

      # @return [String] The path to the cookbook inventory
      attr_reader :inventory_directory

      # @param [Hash] opts
      # @option opts [String] :inventory_directory The path to the cookbook inventory
      def initialize(opts)
        @inventory_directory = opts[:inventory_directory]
        @data_structure = {}

        generate
      end

      # Get a JSON representation of the most recent version of each cookbook
      # found in the inventory_directory.
      # @return [Hash]
      def to_json
        map do |cookbook_name, cookbook_versions|
          cookbook_versions.first.to_hash.merge(available_versions: cookbook_versions.size)
        end.to_json
      end

      def_delegators :data_structure, :each, :keys, :values, :[]

      # Get a non-nested version of the cookbooks structure
      def individual_cookbooks
        values.flatten
      end

      # Add a cookbook to the data structure.
      # @param [Minimart::Cookbook] cookbook The cookbook to add
      def add(cookbook)
        data_structure[cookbook.name] ||= []
        data_structure[cookbook.name] << cookbook
      end

      private

      attr_reader :data_structure

      def generate
        build_data_structure
        sort_data
      end

      def build_data_structure
        cookbooks.each { |cookbook| add(cookbook) }
      end

      # Sort cookbooks in version desc order
      def sort_data
        data_structure.values.map! do |versions|
          versions.sort!.reverse!
        end
      end

      def cookbooks
        inventory_cookbook_paths.map { |path| Minimart::Cookbook.from_path(path) }
      end

      def inventory_cookbook_paths
        Utils::FileHelper.find_cookbooks_in_directory(inventory_directory)
      end

    end
  end
end
