require 'yaml'

module Minimart
  class Mirror
    class InventoryConfiguration

      attr_reader :inventory_config_path,
                  :configuration

      def initialize(inventory_config_path)
        @inventory_config_path = inventory_config_path
        @configuration         = parse_config_file
      end

      def sources
        @sources ||= configuration[:sources].map do |source_url|
          Source.new(source_url)
        end
      end

      def cookbooks
        configuration[:cookbooks].map do |name, requirements|
          if requirements[:type] == 'git'
            build_cookbooks_from_git_location(name, requirements)
          else
            build_cookbooks_from_supermarket_location(name, requirements)
          end
        end.flatten
      end

      private

      def parse_config_file
        unless Utils::FileHelper.file_exists?(inventory_config_path)
          raise InvalidInventoryError, 'The inventory configuration file could not be found'
        end

        file  = File.open(inventory_config_path)
        yaml  = YAML.load(file)
        Utils::HashWithIndifferentAccess.new(yaml)
      end

      def build_cookbooks_from_git_location(name, requirements)
        []
      end

      def build_cookbooks_from_supermarket_location(name, requirements)
        requirements[:versions].map do |version|
          InventoryCookbook::BaseCookbook.new(name, version_requirement: version)
        end
      end
    end

    class InvalidInventoryError < Exception; end
  end
end
