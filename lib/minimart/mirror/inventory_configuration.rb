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
        @sources ||= Sources.new(configuration[:sources])
      end

      def cookbooks
        @cookbooks ||= parse_cookbooks
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

      def parse_cookbooks
        configuration[:cookbooks].map do |name, reqs|
          build_cookbooks(name, reqs.fetch(:versions, [])) +
            build_git_cookbooks(name, reqs.fetch(:git, {})) +
            build_local_cookbooks(name, reqs.fetch(:path, nil))
        end.flatten.compact
      end

      def build_cookbooks(name, requirements)
        requirements.map do |version|
          InventoryCookbook::BaseCookbook.new(name, version_requirement: version)
        end
      end

      def build_git_cookbooks(name, reqs)
        cookbooks_from_branches(name, reqs[:url], reqs.fetch(:branches, [])) +
          cookbooks_from_tags(name, reqs[:url], reqs.fetch(:tags, [])) +
          cookbooks_from_refs(name, reqs[:url], reqs.fetch(:refs, []))
      end

      def build_local_cookbooks(name, path)
        path ? [InventoryCookbook::LocalCookbook.new(name, path: path)] : []
      end

      def cookbooks_from_branches(name, url, branches)
        branches.map do |branch|
          InventoryCookbook::GitCookbook.new(name, url: url, branch: branch)
        end
      end

      def cookbooks_from_tags(name, url, tags)
        tags.map do |tag|
          InventoryCookbook::GitCookbook.new(name, url: url, tag: tag)
        end
      end

      def cookbooks_from_refs(name, url, refs)
        refs.map do |ref|
          InventoryCookbook::GitCookbook.new(name, url: url, ref: ref)
        end
      end
    end

    class InvalidInventoryError < Exception; end
  end
end
