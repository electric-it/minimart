require 'minimart/web/dashboard_generator'
require 'minimart/web/cookbook_show_page_generator'
require 'minimart/web/web_data_generator'

module Minimart
  module Web
    class HtmlGenerator
      include TemplateHelper

      attr_reader :web_directory
      attr_reader :cookbooks

      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
      end

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
