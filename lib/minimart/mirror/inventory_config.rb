require 'yaml'

module Minimart
  class Mirror
    class InventoryConfig

      attr_reader :inventory_config_path,
                  :config_contents

      def initialize(inventory_config_path)
        @inventory_config_path = inventory_config_path
        @config_contents       = parse_config_file
      end

      def parse_sources
        @sources ||= Source::SourceList.new.tap do |source_list|
          config_contents.map do |endpoint, attrs|
            source_list.build_source(endpoint, Utils::HashWithIndifferentAccess.new(attrs))
          end
        end
      end

      private

      def parse_config_file
        unless Utils::FileHelper.file_exists?(inventory_config_path)
          raise InvalidInventoryError.new 'The inventory configuration file could not be found'
        end

        YAML.load(File.open(inventory_config_path))
      end
    end

    class InvalidInventoryError < Exception; end
  end
end
