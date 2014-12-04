module Minimart
  module Download
    class Supermarket

      def self.download(cookbook)
        ##
        # TODO support all Berkshelf API sources
        ##
        Configuration.output.puts "-- Downloading #{cookbook.name} #{cookbook.version}"
        details = Utils::Http.get_json(cookbook.location_path, "cookbooks/#{cookbook.name}/versions/#{cookbook.version.gsub('.', '_')}")
        archive_file = Utils::Http.get_binary("#{cookbook.name}-#{cookbook.version}", details['file'])
        directory    = Dir.mktmpdir
        Utils::Archive.extract_archive(archive_file, directory)
        return directory
      end

    end
  end
end
