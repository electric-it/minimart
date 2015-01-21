module Minimart
  module Download

    # Supermarket will download a cookbook from one of the inventory specified sources.
    class Supermarket

      # Download the given cookbook.
      # @param [Minimart::Mirror::RemoteCookbook] cookbook The cookbook to download.
      # @yield [Dir] Tmp directory containing the cookbook. This directory will be removed when the block exits.
      def self.download(cookbook, &block)
        Configuration.output.puts "-- Downloading #{cookbook.name} #{cookbook.version}"
        details      = Utils::Http.get_json(cookbook.location_path, "cookbooks/#{cookbook.name}/versions/#{cookbook.version.gsub('.', '_')}")
        archive_file = Utils::Http.get_binary("#{cookbook.name}-#{cookbook.version}", details['file'])
        Dir.mktmpdir do |directory|
          Utils::Archive.extract_archive(archive_file, directory)
          block.call(directory)
        end
      end

    end
  end
end
