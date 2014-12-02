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
        @cookbooks ||= configuration[:cookbooks].map do |name, requirements|
          result = []
          result.concat(build_cookbooks(name, requirements[:versions]))
          result.concat(build_git_cookbooks(name, requirements[:git]))
          result
        end.flatten.compact
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

      def build_cookbooks(name, requirements)
        requirements ||= []
        requirements.map do |version|
          InventoryCookbook::BaseCookbook.new(name, version_requirement: version)
        end
      end

      def build_git_cookbooks(name, requirements)
        result = []

        requirements ||= {}
        result.concat((requirements[:branches] || []).map do |branch|
          InventoryCookbook::GitCookbook.new(name,
            url: requirements[:url],
            branch: branch)
        end)

        result.concat((requirements[:tags] || []).map do |tag|
          InventoryCookbook::GitCookbook.new(name,
            url: requirements[:url],
            tag: tag)
        end)

        result.concat((requirements[:refs] || []).map do |ref|
          InventoryCookbook::GitCookbook.new(name,
            url: requirements[:url],
            ref: ref)
        end)

        result
      end
    end

    class InvalidInventoryError < Exception; end
  end
end
