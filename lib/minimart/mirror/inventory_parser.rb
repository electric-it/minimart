require 'yaml'

module Minimart
  class Mirror
    class InventoryParser

      attr_reader :inventory_config_path,
                  :configuration

      def initialize(inventory_config_path)
        @inventory_config_path = inventory_config_path
        @configuration         = parse_config_file
      end

      def sources
        configuration[:sources]
      end

      def cookbooks
        configuration[:cookbooks]
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
    end

    class InvalidInventoryError < Exception; end
  end
end
