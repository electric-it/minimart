require 'yaml'

module Minimart
  class Mirror
    class InventoryConfig

      attr_reader :config_contents

      def initialize(inventory_config_path)
        @config_contents = parse_config_file(inventory_config_path)
      end

      def sources
        @sources ||= config_contents.map do |endpoint, attrs|
          Minimart::Mirror::Source.new(endpoint, attrs['cookbooks'])
        end
      end

      private

      def parse_config_file(path)
        unless Utils::FileHelper.file_exists?(path)
          raise InvalidInventoryError.new 'The inventory configuration file could not be found'
        end

        YAML.load(File.open(path))
      end
    end

    class InvalidInventoryError < Exception; end
  end
end
