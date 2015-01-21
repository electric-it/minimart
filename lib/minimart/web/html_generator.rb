require 'minimart/web/dashboard_generator'
require 'minimart/web/cookbook_show_page_generator'

module Minimart
  module Web

    # HTML generator coordinated building the various HTML pages (dashboard, show pages).
    class HtmlGenerator
      include Minimart::Web::TemplateHelper

      # @return [String] the directory to put any generated HTML in
      attr_reader :web_directory

      # @return [Minimart::Web::Cookbooks] the set of cookbooks to generate HTML for
      attr_reader :cookbooks

      # @param [Hash] opts
      # @option opts [String] :web_directory The directory to put any generated HTML in
      # @option opts [String] :cookbooks The cookbooks to generate HTML for
      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
      end

      # Generate any HTML!
      def generate
        copy_assets
        generate_index
        generate_cookbook_show_pages
      end

      private

      def copy_assets
        FileUtils.cp_r(File.join(minimart_web_directory, 'assets'), web_directory)
      end

      def generate_index
        DashboardGenerator.new(
          web_directory: web_directory,
          cookbooks:     cookbooks).generate
      end

      def generate_cookbook_show_pages
        CookbookShowPageGenerator.new(
          web_directory: web_directory,
          cookbooks:     cookbooks).generate
      end

    end
  end
end
