module Minimart
  module Web
    # This class is responsible for generating the universe.json file, and the
    # related directory structure of gzipped cookbooks.
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
        make_cookbook_files_directory
        create_universe
        write_universe_file
      end

      private

      def make_cookbook_files_directory
        FileUtils.mkdir_p(cookbook_files_directory)
      end

      def create_universe
        cookbooks.individual_cookbooks.each do |cookbook|
          make_cookbook_directory(cookbook)
          generate_archive_file(cookbook)
          add_cookbook_to_universe(cookbook)
        end
      end

      def make_cookbook_directory(cookbook)
        FileUtils.mkdir_p(cookbook_directory(cookbook.name))
      end

      # /web/cookbook_files/cookbook-name
      def cookbook_directory(cookbook_name)
        File.join(cookbook_files_directory, cookbook_name)
      end

      def generate_archive_file(cookbook)
        FileUtils.mkdir_p(archive_directory(cookbook))

        Utils::Archive.pack_archive(
          cookbook.path.dirname.to_s,
          cookbook.path.basename.to_s,
          archive_name(cookbook))
      end

      def archive_name(cookbook)
        File.join(archive_directory(cookbook), "#{cookbook}.tar.gz")
      end

      # /web/cookbook_files/cookbook-name/cookbook-version
      def archive_directory(cookbook)
        File.join(cookbook_directory(cookbook.name), cookbook.web_friendly_version)
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
        File.open(File.join(web_directory, 'universe.json'), 'w+') do |f|
          f.write(universe.to_json)
        end
      end

      def cookbook_files_directory
        @cookbook_files_directory ||= File.join(web_directory, '/cookbook_files')
      end
    end
  end
end
