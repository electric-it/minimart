module Minimart
  class Web
    # Given a path to the inventory directory, this class will generate the necessary
    # JSON output to power the main dashboard, and return cookbooks in a format
    # that can be used to build the various web pages.
    class WebDataGenerator
      include TemplateHelper

      FILE_NAME = 'data.json'

      attr_reader :web_directory
      attr_reader :inventory_directory

      def initialize(opts)
        @web_directory       = opts[:web_directory]
        @inventory_directory = opts[:inventory_directory]
      end

      def generate
        build_data_structure
        sort_data
        write_data_file
        return data_structure
      end

      private

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
            Gem::Version.new(a.version) <=> Gem::Version.new(b.version)
          end
        end
      end

      def write_data_file
        File.open(file_path, 'w+') { |f| f.write(json_data_structure) }
      end

      def file_path
        @file_path ||= File.join(web_directory, FILE_NAME)
      end

      def cookbooks
        inventory_cookbook_paths.map do |path|
          Minimart::Cookbook.new(path)
        end
      end

      def inventory_cookbook_paths
        Utils::FileHelper.find_cookbooks_in_directory(inventory_directory)
      end

      def json_data_structure
        data_structure.map do |cookbook_name, cookbook_versions|
          cookbook_versions.first.to_hash.merge(available_versions: cookbook_versions.size)
        end.to_json
      end

    end
  end
end
