require 'octokit'
require 'ridley'

require 'minimart/utils/archive'
require 'minimart/utils/http'

module Minimart
  module Download
    # This class will download a cookbook from one of the inventory specified sources.
    class Cookbook

      # @return [Minimart::Mirror::SourceCookbook] The cookbook to download
      attr_reader :cookbook

      # @param [Minimart::Mirror::SourceCookbook] cookbook The cookbook to download
      def initialize(cookbook)
        @cookbook = cookbook
      end

      # Download the cookbook
      # @yield Minimart::Cookbook]
      def fetch(&block)
        Configuration.output.puts "-- Downloading #{cookbook.name} #{cookbook.version}"

        unless respond_to?("download_#{cookbook.location_type}", true)
          raise Minimart::Error::UnknownLocationType,
            "Minimart cannot download #{cookbook.name} because it has an unknown location type #{cookbook.location_type}"
        end

        Dir.mktmpdir do |dir|
          send("download_#{cookbook.location_type}", dir)
          block.call(Minimart::Cookbook.from_path(dir)) if block
        end
      end

      private

      def download_opscode(dir)
        details = Utils::Http.get_json(cookbook.location_path, "cookbooks/#{cookbook.name}/versions/#{cookbook.web_friendly_version}")
        get_archive(details['file'], dir)
      end

      def download_uri(dir)
        get_archive(cookbook.location_path, dir)
      end

      def download_chef_server(dir)
        conn = Minimart::Configuration.chef_server_config.merge(
          server_url: cookbook.location_path,
          ssl: {verify: Minimart::Configuration.verify_ssl})

        Ridley.open(conn) do |ridley_client|
          ridley_client.cookbook.download(cookbook.name, cookbook.version, dir)
        end
      end

      def download_github(dir)
        conn = Minimart::Configuration.github_config.merge(
          connection_options: {ssl: {verify: Minimart::Configuration.verify_ssl}})

        location_path = cookbook.location_path_uri
        client        = Octokit::Client.new(conn)
        url           = client.archive_link(location_path.path.gsub(/\A\//, ''), ref: "v#{cookbook.version}")

        get_archive(url, dir)
      end

      def get_archive(url, dir)
        archive_file = Utils::Http.get_binary("#{cookbook.name}-#{cookbook.version}", url)
        Utils::Archive.extract_archive(archive_file, dir)
      end

    end
  end
end
