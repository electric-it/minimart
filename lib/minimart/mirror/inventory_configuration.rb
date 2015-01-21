require 'yaml'
require 'minimart/mirror/inventory_requirements'

module Minimart
  module Mirror

    # This class is responsible for parsing a user defined Minimart configuration file.
    class InventoryConfiguration

      # The path to the inventory configuration file
      attr_reader :inventory_config_path

      # @param [String] inventory_config_path The path to the inventory configuration file
      def initialize(inventory_config_path)
        @inventory_config_path = inventory_config_path
        @configuration         = parse_config_file
      end

      # The collection of files defined in the inventory file
      # @return [Minimart::Mirror::Sources]
      def sources
        @sources ||= Sources.new(raw_sources)
      end

      # The collection of cookbook requirements defined in the inventory file
      # @return [Array]
      def requirements
        @cookbooks ||= InventoryRequirements.new(raw_cookbooks)
      end

      private

      # The raw parsed configuration file
      attr_reader :configuration

      def parse_config_file
        unless Utils::FileHelper.file_exists?(inventory_config_path)
          raise Error::InvalidInventoryError, 'The inventory configuration file could not be found'
        end

        YAML.load(File.open(inventory_config_path).read)
      end

      def raw_sources
        configuration['sources'] || []
      end

      def raw_cookbooks
        configuration['cookbooks'].tap do |cookbooks|
          if cookbooks.nil? || cookbooks.empty?
            raise Error::InvalidInventoryError, 'Minimart could not find any cookbooks defined in the inventory'
          end
        end
      end

    end
  end
end
