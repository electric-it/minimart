require 'yaml'
require 'fileutils'

module Minimart
  class Mirror
    class Inventory

      attr_reader :inventory_config,
                  :inventory_directory,
                  :downloaded_cookbooks

      def initialize(opts = {})
        @inventory_config    = parse_config_file(opts[:inventory_config])
        @inventory_directory = opts[:inventory_directory]
      end

      def build
        make_inventory_directory
        download_cookbooks!
      end

      private

      def make_inventory_directory
        FileUtils.mkdir_p inventory_directory
      end

      def download_cookbooks!
        Minimart::Configuration.output.puts "Building inventory..."

        @downloaded_cookbooks ||= base_source.download_cookbooks do |cookbook, archived_cookbook|
          destination = "#{inventory_directory}/#{cookbook.name}-#{cookbook.version}"
          Minimart::Lib::Archive.extract_archive(archived_cookbook, destination)
        end

        Minimart::Configuration.output.puts "Done building inventory..."
      end

      def base_source
        @base_source ||= Minimart::Mirror::Source.new(inventory_config['base_source'])
      end

      def parse_config_file(path)
        YAML.load(File.open(path))
      end

    end
  end
end
