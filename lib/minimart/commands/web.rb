require 'minimart/web/universe_generator'
require 'minimart/web/html_generator'

module Minimart
  module Commands
    class Web

      attr_reader :inventory_directory
      attr_reader :web_directory
      attr_reader :web_endpoint
      attr_reader :can_generate_html

      def initialize(opts = {})
        @inventory_directory = File.expand_path(opts[:inventory_directory])
        @web_directory       = File.expand_path(opts[:web_directory])
        @web_endpoint        = opts[:web_endpoint]
        @can_generate_html   = opts.fetch(:html, true)
      end

      def execute!
        make_web_directory
        generate_universe
        generate_html
      end

      private

      attr_reader :cookbooks

      def make_web_directory
        FileUtils.mkdir_p web_directory
      end

      def generate_universe
        generator = Minimart::Web::UniverseGenerator.new(
          web_directory: web_directory,
          endpoint:      web_endpoint,
          cookbooks:     cookbooks)

        generator.generate
      end

      def generate_html
        return unless generate_html?

        generator = Minimart::Web::HtmlGenerator.new(
          web_directory: web_directory,
          cookbooks:     cookbooks)

        generator.generate
      end

      def cookbooks
        @cookbooks ||= Minimart::Web::Cookbooks.new(inventory_directory: inventory_directory)
      end

      def generate_html?
        can_generate_html
      end

    end
  end
end
