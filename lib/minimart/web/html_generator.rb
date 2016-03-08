require 'sprockets'
require 'sass'
require 'uglifier'

require 'minimart/web/dashboard_generator'
require 'minimart/web/cookbook_show_page_generator'

module Minimart
  module Web

    # HTML generator coordinated building the various HTML pages (dashboard, show pages).
    class HtmlGenerator
      include Minimart::Web::TemplateHelper

      attr_reader :web_directory, :cookbooks, :clean_cookbooks

      # @param [Hash] opts
      # @option opts [String] :web_directory The directory to put any generated HTML in
      # @option opts [String] :cookbooks The cookbooks to generate HTML for
      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @cookbooks     = opts[:cookbooks]
        @clean_cookbooks = opts.fetch(:clean_cookbooks, true)
      end

      # Generate any HTML!
      def generate
        generate_assets
        generate_index
        generate_cookbook_show_pages
      end

      private

      def generate_assets
        generate_js
        generate_css
        copy_assets
      end

      def copy_assets
        FileUtils.cp_r(compiled_asset_directory, web_directory)
      end

      def generate_js
        js_dir = Pathname.new(compiled_asset_directory).join('javascripts')
        FileUtils.mkdir_p(js_dir)
        sprockets = Sprockets::Environment.new(minimart_root_directory)
        sprockets.js_compressor = :uglify
        sprockets.append_path(Pathname.new(raw_asset_directory).join('javascripts'))
        sprockets['manifest.js'].write_to(js_dir.join('application.min.js'))
      end

      def generate_css
        css_dir = Pathname.new(compiled_asset_directory).join('stylesheets')
        FileUtils.mkdir_p(css_dir)
        sprockets = Sprockets::Environment.new(minimart_root_directory)
        sprockets.css_compressor = :sass
        sprockets.append_path(Pathname.new(raw_asset_directory).join('stylesheets'))
        sprockets['manifest.css'].write_to(css_dir.join('application.min.css'))
      end

      def generate_index
        DashboardGenerator.new(
          web_directory: web_directory,
          cookbooks:     cookbooks).generate
      end

      def generate_cookbook_show_pages
        CookbookShowPageGenerator.new(
          web_directory: web_directory,
          cookbooks:     cookbooks,
          clean_cookbooks: clean_cookbooks).generate
      end

    end
  end
end
