require 'minimart/web/template_helper'

module Minimart
  module Web
    # This class is responsible for generating the universe.json file.
    class UniverseGenerator
      include TemplateHelper

      attr_reader :web_directory
      attr_reader :endpoint
      attr_reader :universe
      attr_reader :cookbooks

      def initialize(opts = {})
        @web_directory = opts[:web_directory]
        @endpoint      = opts[:endpoint]
        @cookbooks     = opts[:cookbooks]
        @universe      = {}
      end

      def generate
        FileUtils.mkdir_p web_cookbook_base_path

        cookbooks.values.each do |cookbook_versions|
          cookbook_versions.each do |cookbook|
            make_cookbook_directory(cookbook)
            generate_archive_file(cookbook)
            add_cookbook_to_universe(cookbook)
          end
        end

        write_universe_file
      end

      private

      def web_cookbook_base_path
        @web_cookbook_base_path ||= File.join(web_directory, '/cookbook_files')
      end

      def make_cookbook_directory(cookbook)
        FileUtils.mkdir_p(web_cookbook_path(cookbook.name))
      end

      def web_cookbook_path(cookbook_name)
        File.join(web_cookbook_base_path, cookbook_name)
      end

      def generate_archive_file(cookbook)
        FileUtils.mkdir_p(archive_path(cookbook))
        Utils::Archive.pack_archive(cookbook.path.dirname, cookbook.path.basename, archive_name(cookbook))
      end

      def archive_path(cookbook)
        File.join(web_cookbook_path(cookbook.name), cookbook.web_friendly_version)
      end

      def archive_name(cookbook)
        File.join(archive_path(cookbook), "#{cookbook}.tar.gz")
      end

      def add_cookbook_to_universe(cookbook)
        universe[cookbook.name] ||= {}
        universe[cookbook.name][cookbook.version.to_s] = {
          location_type:  :uri,
          location_path:  archive_url(cookbook),
          download_url:   archive_url(cookbook),
          dependencies:   cookbook.dependencies
        }
      end

      def archive_url(cookbook)
        Utils::Http.build_url(endpoint, cookbook_download_path(cookbook))
      end

      def write_universe_file
        File.open(File.join(web_directory, 'universe'), 'w+') do |f|
          f.write(universe.to_json)
        end
      end
    end
  end
end
