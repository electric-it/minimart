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
        @sources ||= Sources.new(raw_sources)
      end

      def requirements
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
        raw_cookbooks.map do |name, reqs|
          market_requirements(name, reqs) + git_requirements(name, reqs) + local_path_requirements(name, reqs)
        end.flatten.compact
      end

      def market_requirements(name, reqs)
        CookbookRequirementsBuilder.new(name, reqs).build
      end

      def git_requirements(name, reqs)
        GitRequirementsBuilder.new(name, reqs.fetch(:git, {})).build
      end

      def local_path_requirements(name, reqs)
        LocalRequirementsBuilder.new(name, reqs).build
      end

      def raw_sources
        configuration[:sources]
      end

      def raw_cookbooks
        configuration[:cookbooks]
      end
    end


    class CookbookRequirementsBuilder
      attr_reader :name,
                  :versions

      def initialize(name, reqs)
        @name     = name
        @versions = reqs.fetch(:versions, [])
      end

      def build
        versions.map do |v|
          InventoryRequirement::BaseRequirement.new(name, version_requirement: v)
        end
      end
    end


    class GitRequirementsBuilder

      attr_reader :name,
                  :url,
                  :branches,
                  :tags,
                  :refs

      def initialize(name, reqs)
        @name     = name
        @url      = reqs[:url]
        @branches = reqs.fetch(:branches, [])
        @tags     = reqs.fetch(:tags, [])
        @refs     = reqs.fetch(:refs, [])
      end

      def build
        from_branches + from_tags + from_refs
      end

      private

      def from_branches
        branches.map { |b| build_requirement(:branch, b) }
      end

      def from_tags
        tags.map { |t| build_requirement(:tag, t) }
      end

      def from_refs
        refs.map { |r| build_requirement(:ref, r) }
      end

      def build_requirement(type, value)
        InventoryRequirement::GitRequirement.new(name, url: url, type => value)
      end
    end


    class LocalRequirementsBuilder
      attr_reader :name,
                  :path

      def initialize(name, reqs)
        @name = name
        @path = reqs[:path]
      end

      def build
        return [] unless path
        [InventoryRequirement::LocalPathRequirement.new(name, path: path)]
      end
    end

    class InvalidInventoryError < Exception; end
  end
end
