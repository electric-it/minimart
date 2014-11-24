require 'yaml'

module Minimart
  class Mirror
    class InvalidInventoryError < Exception; end

    class Inventory

      attr_reader :inventory_config,
                  :inventory_directory

      def initialize(opts = {})
        raise ArgumentError.new('missing required :inventory_config option') if opts[:inventory_config].nil?

        @inventory_config    = parse_config_file(opts[:inventory_config])
        @inventory_directory = opts[:inventory_directory]
      end

      def build
        make_inventory_directory
        download_cookbooks!
      end

      private

      def make_inventory_directory
        Utils::FileHelper.make_directory(inventory_directory)
      end

      def download_cookbooks!
        Configuration.output.puts "Building inventory..."

        sources.each do |source|
          source.download_cookbooks do |cookbook, archived_cookbook|
            Utils::Archive.extract_cookbook(archived_cookbook, inventory_destination(cookbook))
          end
        end

        Configuration.output.puts "Done building inventory..."
      end

      def inventory_destination(cookbook)
        "#{inventory_directory}/#{cookbook.name}-#{cookbook.version}"
      end

      def sources
        @sources ||= inventory_config.map do |endpoint, attrs|
          Minimart::Mirror::Source.new(endpoint, attrs['cookbooks'])
        end
      end

      def parse_config_file(path)
        raise InvalidInventoryError.new('The inventory configuration file could not be found') unless Utils::FileHelper.file_exists?(path)

        YAML.load(File.open(path))
      end

    end
  end
end
