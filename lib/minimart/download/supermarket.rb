module Minimart
  module Download
    class Supermarket

      def self.download(cookbook)
        ##
        # TODO support all Berkshelf API sources
        ##
        Configuration.output.puts "-- Downloading #{cookbook.name} #{cookbook.version}"
        archive_file = Utils::Http.get_binary("#{cookbook.name}-#{cookbook.version}", cookbook.download_url)
        directory    = Dir.mktmpdir
        Utils::Archive.extract_archive(archive_file, directory)
        return directory
      end

    end
  end
end
